-- Simple seed: 10 users and 5 products per user with random main/sub, 3 images, 3 keywords

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

SET @now := NOW();

-- 1) Insert 10 users (idempotent)
INSERT INTO
    users (
        id,
        first_name,
        last_name,
        email,
        password_hash,
        user_type,
        status,
        phone_number,
        created_at,
        updated_at
    )
SELECT UUID(), CONCAT('Seed', t.n), 'User', CONCAT('seed', t.n, '@example.com'), SHA2('password', 256), 'SELLER', 'ACTIVE', CONCAT(
        '+91-90000', LPAD(t.n, 4, '0')
    ), @now, @now
FROM (
        SELECT 1 n
        UNION ALL
        SELECT 2
        UNION ALL
        SELECT 3
        UNION ALL
        SELECT 4
        UNION ALL
        SELECT 5
        UNION ALL
        SELECT 6
        UNION ALL
        SELECT 7
        UNION ALL
        SELECT 8
        UNION ALL
        SELECT 9
        UNION ALL
        SELECT 10
    ) t
WHERE
    NOT EXISTS (
        SELECT 1
        FROM users u
        WHERE
            u.email = CONCAT('seed', t.n, '@example.com')
    );

-- 2) Insert 5 products per seed user
INSERT INTO
    products (
        id,
        name,
        description,
        price,
        category_id,
        seller_id,
        image_url,
        is_veg,
        is_available,
        preparation_time,
        main_category_id,
        sub_category_id,
        created_at,
        updated_at
    )
SELECT
    UUID() AS id,
    CONCAT(
        'Seed Product ',
        LPAD(FLOOR(RAND() * 10000), 4, '0')
    ) AS name,
    'Auto-seeded product' AS description,
    ROUND(50 + RAND() * 450, 2) AS price,
    -- Resolve legacy categories.id by chosen sub (fallback to main)
    COALESCE(
        (
            SELECT c.id
            FROM
                sub_categories sc
                JOIN categories c ON c.name = sc.name
            WHERE
                sc.id = (
                    @sub := (
                        SELECT sc2.id
                        FROM sub_categories sc2
                        WHERE
                            sc2.is_active = 1
                        ORDER BY RAND()
                        LIMIT 1
                    )
                )
            LIMIT 1
        ),
        (
            SELECT c2.id
            FROM
                main_categories mc2
                JOIN categories c2 ON c2.name = mc2.name
            WHERE
                mc2.id = (
                    SELECT sc3.main_category_id
                    FROM sub_categories sc3
                    WHERE
                        sc3.id = @sub
                )
            LIMIT 1
        )
    ) AS category_id,
    su.user_id AS seller_id,
    NULL AS image_url,
    IF(RAND() > 0.5, 1, 0) AS is_veg,
    1 AS is_available,
    FLOOR(5 + RAND() * 50) AS preparation_time,
    (
        SELECT sc4.main_category_id
        FROM sub_categories sc4
        WHERE
            sc4.id = @sub
    ) AS main_category_id,
    @sub AS sub_category_id,
    @now,
    @now
FROM (
        SELECT id AS user_id
        FROM users
        WHERE
            email LIKE 'seed%@example.com'
        ORDER BY email
        LIMIT 10
    ) su
    CROSS JOIN (
        SELECT 1 n
        UNION ALL
        SELECT 2
        UNION ALL
        SELECT 3
        UNION ALL
        SELECT 4
        UNION ALL
        SELECT 5
    ) five;

-- 3) Add 3 images per new product (reuse random existing URLs or sample uploads)
INSERT INTO
    product_images (
        id,
        product_id,
        image_url,
        `order`
    )
SELECT UUID(), p.id, COALESCE(
        (
            SELECT image_url
            FROM product_images
            WHERE
                image_url IS NOT NULL
            ORDER BY RAND()
            LIMIT 1
        ), '/uploads/sample1.jpg'
    ), 1
FROM products p
WHERE
    p.created_at >= @now
    AND p.seller_id IN (
        SELECT id
        FROM users
        WHERE
            email LIKE 'seed%@example.com'
    );

INSERT INTO
    product_images (
        id,
        product_id,
        image_url,
        `order`
    )
SELECT UUID(), p.id, COALESCE(
        (
            SELECT image_url
            FROM product_images
            WHERE
                image_url IS NOT NULL
            ORDER BY RAND()
            LIMIT 1
        ), '/uploads/sample2.jpg'
    ), 2
FROM products p
WHERE
    p.created_at >= @now
    AND p.seller_id IN (
        SELECT id
        FROM users
        WHERE
            email LIKE 'seed%@example.com'
    );

INSERT INTO
    product_images (
        id,
        product_id,
        image_url,
        `order`
    )
SELECT UUID(), p.id, COALESCE(
        (
            SELECT image_url
            FROM product_images
            WHERE
                image_url IS NOT NULL
            ORDER BY RAND()
            LIMIT 1
        ), '/uploads/sample3.jpg'
    ), 3
FROM products p
WHERE
    p.created_at >= @now
    AND p.seller_id IN (
        SELECT id
        FROM users
        WHERE
            email LIKE 'seed%@example.com'
    );

-- 4) Attach 3 relevant keywords per product created in this run
INSERT IGNORE INTO
    product_keywords (product_id, keyword_id)
SELECT product_id, keyword_id
FROM (
        SELECT
            p.id AS product_id, k.id AS keyword_id, ROW_NUMBER() OVER (
                PARTITION BY
                    p.id
                ORDER BY RAND()
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
            p.created_at >= @now
            AND p.seller_id IN (
                SELECT id
                FROM users
                WHERE
                    email LIKE 'seed%@example.com'
            )
    ) z
WHERE
    z.rn <= 3;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;