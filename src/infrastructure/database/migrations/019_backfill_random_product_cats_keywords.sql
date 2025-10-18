-- Backfill existing products with random main/sub categories and relevant keywords
-- Deterministic randomness using CRC32-based seeds so re-runs are stable

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

-- 1) Assign main_category_id and sub_category_id where missing
UPDATE products p
JOIN (
    SELECT
        p.id AS pid,
        (
            SELECT mc.id
            FROM main_categories mc
            WHERE
                mc.is_active = 1
            ORDER BY RAND(CRC32(p.id))
            LIMIT 1
        ) AS rand_main_id,
        (
            SELECT sc.id
            FROM sub_categories sc
            WHERE
                sc.is_active = 1
                AND sc.main_category_id = (
                    SELECT mc2.id
                    FROM main_categories mc2
                    WHERE
                        mc2.is_active = 1
                    ORDER BY RAND(CRC32(p.id))
                    LIMIT 1
                )
            ORDER BY RAND(CRC32(CONCAT(p.id, '-sub')))
            LIMIT 1
        ) AS rand_sub_id
    FROM products p
) x ON x.pid = p.id
SET
    p.main_category_id = COALESCE(
        p.main_category_id,
        x.rand_main_id
    ),
    p.sub_category_id = COALESCE(
        p.sub_category_id,
        x.rand_sub_id
    )
WHERE
    p.main_category_id IS NULL
    OR p.sub_category_id IS NULL;

-- 2) Insert up to 4 keywords per product, chosen from the product's main (and sub when available)
--    Skip any keyword already linked to the product
INSERT IGNORE INTO
    product_keywords (product_id, keyword_id)
SELECT pid, keyword_id
FROM (
        SELECT p.id AS pid, k.id AS keyword_id, ROW_NUMBER() OVER (
                PARTITION BY
                    p.id
                ORDER BY RAND(
                        CRC32(CONCAT(p.id, ':', k.id))
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