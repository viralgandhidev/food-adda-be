-- Seed: 10 users, and for each user 5 products with random categories,
--  at least 3 images (from uploads or existing), and 3 keywords

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

-- 0) Helpers: small sequences
WITH RECURSIVE
    seq10 (n) AS (
        SELECT 1
        UNION ALL
        SELECT n + 1
        FROM seq10
        WHERE
            n < 10
    ),
    seq5 (n) AS (
        SELECT 1
        UNION ALL
        SELECT n + 1
        FROM seq5
        WHERE
            n < 5
    )
    -- 1) Insert 10 users (idempotent on email)
INSERT INTO
    users (
        id,
        first_name,
        last_name,
        email,
        password,
        user_type,
        created_at,
        updated_at
    )
SELECT UUID(), CONCAT('Seed', n), 'User', CONCAT('seed', n, '@example.com'), SHA2('password', 256), 'SELLER', NOW(), NOW()
FROM seq10
WHERE
    NOT EXISTS (
        SELECT 1
        FROM users u
        WHERE
            u.email = CONCAT('seed', n, '@example.com')
    );

-- 2) Pick the 10 users we just created (or existing matching email pattern)
SET @now := NOW();

-- Create 5 products per user
WITH RECURSIVE
    seq10 (n) AS (
        SELECT 1
        UNION ALL
        SELECT n + 1
        FROM seq10
        WHERE
            n < 10
    ),
    seq5 (n) AS (
        SELECT 1
        UNION ALL
        SELECT n + 1
        FROM seq5
        WHERE
            n < 5
    ),
    seed_users AS (
        SELECT id AS user_id, email
        FROM users
        WHERE
            email LIKE 'seed%@example.com'
        ORDER BY email
        LIMIT 10
    ),
    to_create AS (
        SELECT su.user_id, s5.n AS idx
        FROM seed_users su
            CROSS JOIN seq5 s5
    )
SELECT 'begin_insert' INTO @noop;

-- For each planned product, insert product and related rows
-- Note: Use iterative approach via prepared statements for per-row randomness
SET @i := 0;

DROP TEMPORARY TABLE IF EXISTS _product_plan;

CREATE TEMPORARY TABLE _product_plan (
    user_id VARCHAR(64) NOT NULL,
    plan_idx INT NOT NULL
) ENGINE = Memory;

INSERT INTO
    _product_plan (user_id, plan_idx)
SELECT user_id, idx
FROM to_create;

-- Cursor-like loop emulation
-- (MySQL doesn't have simple cursors in migrations; use repeatable updates.)
-- We'll process in batches
WHILE EXISTS (
    SELECT 1
    FROM _product_plan
) DO
-- Pick one row
SET
    @uid := (
        SELECT user_id
        FROM _product_plan
        LIMIT 1
    );

SET @pidx := ( SELECT plan_idx FROM _product_plan LIMIT 1 );

DELETE FROM _product_plan
WHERE
    user_id = @uid
    AND plan_idx = @pidx
LIMIT 1;

-- Random main category
SET
    @main_id := (
        SELECT mc.id
        FROM main_categories mc
        WHERE
            mc.is_active = 1
        ORDER BY RAND()
        LIMIT 1
    );
-- Random sub under main (nullable)
SET
    @sub_id := (
        SELECT sc.id
        FROM sub_categories sc
        WHERE
            sc.is_active = 1
            AND sc.main_category_id = @main_id
        ORDER BY RAND()
        LIMIT 1
    );
-- Resolve legacy categories.id for FK by name
SET
    @legacy_cat := (
        SELECT c.id
        FROM
            sub_categories sc
            JOIN categories c ON c.name = sc.name
        WHERE
            sc.id = @sub_id
        LIMIT 1
    );

IF @legacy_cat IS NULL THEN
SET
    @legacy_cat := (
        SELECT c.id
        FROM
            main_categories mc
            JOIN categories c ON c.name = mc.name
        WHERE
            mc.id = @main_id
        LIMIT 1
    );

END IF;

-- Create product id
SET @pid := ( SELECT UUID() );

SET
    @pname := CONCAT(
        'Seed Product ',
        LPAD(FLOOR(RAND() * 10000), 4, '0')
    );

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
VALUES (
        @pid,
        @pname,
        'Auto-seeded product',
        ROUND(50 + RAND() * 450, 2),
        @legacy_cat,
        @uid,
        NULL,
        IF(RAND() > 0.5, 1, 0),
        1,
        FLOOR(5 + RAND() * 50),
        @main_id,
        @sub_id,
        @now,
        @now
    );

-- Seed at least 3 images: pull from existing or defaults
SET
    @img1 := (
        SELECT image_url
        FROM product_images
        WHERE
            image_url IS NOT NULL
        ORDER BY RAND()
        LIMIT 1
    );

IF @img1 IS NULL THEN SET @img1 := '/uploads/sample1.jpg';

END IF;

SET
    @img2 := (
        SELECT image_url
        FROM product_images
        WHERE
            image_url IS NOT NULL
        ORDER BY RAND()
        LIMIT 1
    );

IF @img2 IS NULL THEN SET @img2 := '/uploads/sample2.jpg';

END IF;

SET
    @img3 := (
        SELECT image_url
        FROM product_images
        WHERE
            image_url IS NOT NULL
        ORDER BY RAND()
        LIMIT 1
    );

IF @img3 IS NULL THEN SET @img3 := '/uploads/sample3.jpg';

END IF;

INSERT INTO
    product_images (
        id,
        product_id,
        image_url,
        `order`
    )
VALUES (UUID(), @pid, @img1, 1),
    (UUID(), @pid, @img2, 2),
    (UUID(), @pid, @img3, 3);

-- Attach exactly 3 keywords relevant to main/sub
INSERT IGNORE INTO
    product_keywords (product_id, keyword_id)
SELECT @pid, k.id
FROM (
        SELECT k.id
        FROM keywords k
        WHERE
            k.is_active = 1
            AND k.main_category_id = @main_id
            AND (
                @sub_id IS NULL
                OR k.sub_category_id IS NULL
                OR k.sub_category_id = @sub_id
            )
        ORDER BY RAND()
        LIMIT 3
    ) k;

END WHILE;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;