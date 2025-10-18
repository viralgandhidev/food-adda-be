-- Add main_category_id and sub_category_id to products and create FKs

-- Mirror categories.id type for FK columns
SET
    @cat_col_type := (
        SELECT COLUMN_TYPE
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
            AND COLUMN_NAME = 'id'
        LIMIT 1
    );

-- Add columns if not exists
SET
    @has_main := (
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND COLUMN_NAME = 'main_category_id'
    );

SET
    @ddl := IF(
        @has_main = 0,
        CONCAT(
            'ALTER TABLE products ADD COLUMN main_category_id ',
            @cat_col_type,
            ' NULL'
        ),
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SET
    @has_sub := (
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND COLUMN_NAME = 'sub_category_id'
    );

SET
    @ddl := IF(
        @has_sub = 0,
        CONCAT(
            'ALTER TABLE products ADD COLUMN sub_category_id ',
            @cat_col_type,
            ' NULL'
        ),
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Add indexes
SET
    @idx_main := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND INDEX_NAME = 'idx_products_main_category'
    );

SET
    @ddl := IF(
        @idx_main = 0,
        'CREATE INDEX idx_products_main_category ON products (main_category_id)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SET
    @idx_sub := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND INDEX_NAME = 'idx_products_sub_category'
    );

SET
    @ddl := IF(
        @idx_sub = 0,
        'CREATE INDEX idx_products_sub_category ON products (sub_category_id)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Add FKs if not present
SET
    @fk_main := (
        SELECT COUNT(*)
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND CONSTRAINT_NAME = 'fk_products_main'
    );

SET
    @ddl := IF(
        @fk_main = 0,
        'ALTER TABLE products ADD CONSTRAINT fk_products_main FOREIGN KEY (main_category_id) REFERENCES main_categories(id) ON DELETE SET NULL',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SET
    @fk_sub := (
        SELECT COUNT(*)
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND CONSTRAINT_NAME = 'fk_products_sub'
    );

SET
    @ddl := IF(
        @fk_sub = 0,
        'ALTER TABLE products ADD CONSTRAINT fk_products_sub FOREIGN KEY (sub_category_id) REFERENCES sub_categories(id) ON DELETE SET NULL',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;