-- Simple seed: 10 users and 5 products per user with random main/sub, 3 images, 3 keywords
-- Idempotent: Uses INSERT with WHERE NOT EXISTS patterns and timestamp-based filtering

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

SET @now := NOW();

-- 1) Insert 10 users (idempotent - WHERE NOT EXISTS)
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
        SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) t
WHERE
    NOT EXISTS (
        SELECT 1
        FROM users u
        WHERE
            u.email = CONCAT('seed', t.n, '@example.com')
    );

-- 2) Insert 5 products per seed user
-- Simplified approach: Use CROSS JOIN to get combinations, filter by sub_cat.main_category_id
INSERT INTO
    products (
        id, name, description, price, category_id, seller_id, image_url,
        is_veg, is_available, preparation_time, main_category_id, sub_category_id,
        created_at, updated_at
    )
SELECT
    UUID(),
    CONCAT('Seed Product ', LPAD(FLOOR(RAND() * 10000), 4, '0')),
    'Auto-seeded product',
    ROUND(50 + RAND() * 450, 2),
    COALESCE(
        (SELECT c.id FROM sub_categories sc JOIN categories c ON c.name = sc.name WHERE sc.id = sub_cat.id LIMIT 1),
        (SELECT c2.id FROM main_categories mc2 JOIN categories c2 ON c2.name = mc2.name WHERE mc2.id = main_cat.id LIMIT 1)
    ),
    su.user_id,
    NULL,
    IF(RAND() > 0.5, 1, 0),
    1,
    FLOOR(5 + RAND() * 50),
    main_cat.id,
    sub_cat.id,
    @now,
    @now
FROM (
    SELECT id AS user_id FROM users WHERE email LIKE 'seed%@example.com' ORDER BY email LIMIT 10
) su
CROSS JOIN (
    SELECT id FROM main_categories WHERE is_active = 1 ORDER BY RAND() LIMIT 1
) main_cat
CROSS JOIN (
    SELECT id, main_category_id 
    FROM sub_categories 
    WHERE is_active = 1 
      AND main_category_id = (SELECT id FROM main_categories WHERE is_active = 1 ORDER BY RAND() LIMIT 1)
    ORDER BY RAND() 
    LIMIT 1
) sub_cat
CROSS JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) five;

-- 3) Add 3 images per product created in this run (timestamp-based, idempotent via NOT EXISTS)
INSERT INTO
    product_images (id, product_id, image_url, `order`)
SELECT UUID(), p.id, COALESCE(
    (SELECT image_url FROM product_images WHERE image_url IS NOT NULL ORDER BY RAND() LIMIT 1),
    '/uploads/sample1.jpg'
), 1
FROM products p
WHERE p.created_at >= @now
  AND p.seller_id IN (SELECT id FROM users WHERE email LIKE 'seed%@example.com')
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.`order` = 1);

INSERT INTO
    product_images (id, product_id, image_url, `order`)
SELECT UUID(), p.id, COALESCE(
    (SELECT image_url FROM product_images WHERE image_url IS NOT NULL ORDER BY RAND() LIMIT 1),
    '/uploads/sample2.jpg'
), 2
FROM products p
WHERE p.created_at >= @now
  AND p.seller_id IN (SELECT id FROM users WHERE email LIKE 'seed%@example.com')
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.`order` = 2);

INSERT INTO
    product_images (id, product_id, image_url, `order`)
SELECT UUID(), p.id, COALESCE(
    (SELECT image_url FROM product_images WHERE image_url IS NOT NULL ORDER BY RAND() LIMIT 1),
    '/uploads/sample3.jpg'
), 3
FROM products p
WHERE p.created_at >= @now
  AND p.seller_id IN (SELECT id FROM users WHERE email LIKE 'seed%@example.com')
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.`order` = 3);

-- 4) Attach 3 relevant keywords per product created in this run (INSERT IGNORE for idempotency)
INSERT IGNORE INTO
    product_keywords (product_id, keyword_id)
SELECT product_id, keyword_id
FROM (
    SELECT
        p.id AS product_id,
        k.id AS keyword_id,
        ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY RAND()) AS rn
    FROM products p
    JOIN keywords k ON k.is_active = 1
        AND k.main_category_id = p.main_category_id
        AND (p.sub_category_id IS NULL OR k.sub_category_id IS NULL OR k.sub_category_id = p.sub_category_id)
    WHERE p.created_at >= @now
      AND p.seller_id IN (SELECT id FROM users WHERE email LIKE 'seed%@example.com')
      AND NOT EXISTS (
          SELECT 1 FROM product_keywords pk
          WHERE pk.product_id = p.id AND pk.keyword_id = k.id
      )
) z
WHERE z.rn <= 3;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;
