-- Create keywords table (MySQL-safe IF NOT EXISTS via information_schema)

-- Derive categories.id column definition so FK types match exactly
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

-- Also capture categories table default collation and derive charset to apply at table-level
SET
    @cat_tbl_collation := (
        SELECT TABLE_COLLATION
        FROM information_schema.TABLES
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'categories'
        LIMIT 1
    );

SET
    @cat_tbl_charset := (
        SELECT SUBSTRING_INDEX(@cat_tbl_collation, '_', 1)
    );

-- Create table if not exists
SET
    @tbl_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'keywords'
    );

SET
    @ddl := IF(
        @tbl_exists = 0,
        CONCAT(
            'CREATE TABLE keywords (\n',
            '  id ',
            @cat_col_type,
            ' NOT NULL',
            ',\n',
            '  name VARCHAR(255) NOT NULL,\n',
            '  main_category_id ',
            @cat_col_type,
            ' NOT NULL',
            ',\n',
            '  sub_category_id ',
            @cat_col_type,
            ' NULL',
            ',\n',
            '  is_active TINYINT(1) NOT NULL DEFAULT 1,\n',
            '  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n',
            '  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n',
            '  PRIMARY KEY (id),\n',
            '  UNIQUE KEY uq_keywords_name_main_sub (name, main_category_id, sub_category_id),\n',
            '  KEY idx_keywords_main (main_category_id),\n',
            '  KEY idx_keywords_sub (sub_category_id),\n',
            '  CONSTRAINT fk_keywords_main FOREIGN KEY (main_category_id) REFERENCES categories(id) ON DELETE CASCADE,\n',
            '  CONSTRAINT fk_keywords_sub FOREIGN KEY (sub_category_id) REFERENCES categories(id) ON DELETE SET NULL\n',
            ') ENGINE=InnoDB DEFAULT CHARSET=',
            @cat_tbl_charset,
            ' COLLATE ',
            @cat_tbl_collation
        ),
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Ensure indexes exist (in case table already present without them)
SET
    @idx_main := (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'keywords'
            AND INDEX_NAME = 'idx_keywords_main'
    );

SET
    @ddl := IF(
        @idx_main = 0,
        'CREATE INDEX idx_keywords_main ON keywords (main_category_id)',
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
            AND TABLE_NAME = 'keywords'
            AND INDEX_NAME = 'idx_keywords_sub'
    );

SET
    @ddl := IF(
        @idx_sub = 0,
        'CREATE INDEX idx_keywords_sub ON keywords (sub_category_id)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;