-- Ensure categories table supports hierarchy (MySQL-safe)

-- Add parent_id column if missing
SET
    @col_exists := (
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
            AND COLUMN_NAME = 'parent_id'
    );

SET
    @ddl := IF(
        @col_exists = 0,
        'ALTER TABLE categories ADD COLUMN parent_id CHAR(36) NULL AFTER id',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Create index on parent_id if missing
SET
    @idx_parent := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
            AND INDEX_NAME = 'idx_categories_parent'
    );

SET
    @ddl := IF(
        @idx_parent = 0,
        'CREATE INDEX idx_categories_parent ON categories (parent_id)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Create index on is_active if missing
SET
    @idx_active := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
            AND INDEX_NAME = 'idx_categories_active'
    );

SET
    @ddl := IF(
        @idx_active = 0,
        'CREATE INDEX idx_categories_active ON categories (is_active)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Create index on display_order if missing
SET
    @idx_order := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
            AND INDEX_NAME = 'idx_categories_display_order'
    );

SET
    @ddl := IF(
        @idx_order = 0,
        'CREATE INDEX idx_categories_display_order ON categories (display_order)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Optional: add unique (name,parent_id) manually if needed