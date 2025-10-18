-- Align existing products.category_id with new main/sub categories
-- 1) If a product has main_category_id but no sub_category_id, pick a random sub under that main
-- 2) Set products.category_id = COALESCE(sub_category_id, main_category_id)
-- 3) Ensure each product has up to 4 keywords linked (idempotent)

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

-- 1) Choose a random sub for products missing sub but having main
UPDATE products p
JOIN (
    SELECT p.id AS pid, (
            SELECT sc.id
            FROM sub_categories sc
            WHERE
                sc.is_active = 1
                AND sc.main_category_id = p.main_category_id
            ORDER BY RAND(
                    CRC32(CONCAT(p.id, ':sub-pick'))
                )
            LIMIT 1
        ) AS chosen_sub
    FROM products p
    WHERE
        p.sub_category_id IS NULL
        AND p.main_category_id IS NOT NULL
) x ON x.pid = p.id
SET
    p.sub_category_id = x.chosen_sub
WHERE
    p.sub_category_id IS NULL
    AND x.chosen_sub IS NOT NULL;

-- 2) Update legacy category_id to reflect new hierarchy (categories table shares ids)
UPDATE products p
SET
    p.category_id = COALESCE(
        p.sub_category_id,
        p.main_category_id
    )
WHERE
    COALESCE(
        p.sub_category_id,
        p.main_category_id
    ) IS NOT NULL
    AND p.category_id <> COALESCE(
        p.sub_category_id,
        p.main_category_id
    );

-- 3) Backfill up to 4 keywords per product (idempotent)
INSERT IGNORE INTO
    product_keywords (product_id, keyword_id)
SELECT pid, keyword_id
FROM (
        SELECT p.id AS pid, k.id AS keyword_id, ROW_NUMBER() OVER (
                PARTITION BY
                    p.id
                ORDER BY RAND(
                        CRC32(CONCAT(p.id, ':kw:', k.id))
                    )
            ) AS rn
        FROM products p
            JOIN keywords k ON k.is_active = 1
            AND k.main_category_id = p.main_category_id
            AND (
                p.sub_category_id IS NULL
                OR k.sub_category_id IS NULL
                OR k.sub_category_id = p.sub_category_id
            )
        WHERE
            p.main_category_id IS NOT NULL
            AND NOT EXISTS (
                SELECT 1
                FROM product_keywords pk
                WHERE
                    pk.product_id = p.id
                    AND pk.keyword_id = k.id
            )
    ) s
WHERE
    s.rn <= 4;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;