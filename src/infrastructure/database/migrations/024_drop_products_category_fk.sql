-- Deprecate legacy products.category_id FK to categories
-- Make category_id nullable and drop FK so new main/sub logic is authoritative

-- Drop FK if it exists
SET
    @fk_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND CONSTRAINT_NAME = 'products_ibfk_1'
    );

SET
    @ddl := IF(
        @fk_exists > 0,
        'ALTER TABLE products DROP FOREIGN KEY products_ibfk_1',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Align column to be nullable using categories.id type
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

SET
    @ddl := CONCAT(
        'ALTER TABLE products MODIFY category_id ',
        @cat_col_type,
        ' NULL'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;