-- Create main_categories and sub_categories tables (MySQL-safe)

-- Derive categories id type to mirror
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

-- main_categories
SET
    @tbl_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'main_categories'
    );

SET
    @ddl := IF(
        @tbl_exists = 0,
        CONCAT(
            'CREATE TABLE main_categories (\n',
            '  id ',
            @cat_col_type,
            ' NOT NULL,\n',
            '  name VARCHAR(255) NOT NULL,\n',
            '  description TEXT NULL,\n',
            '  image_url VARCHAR(1024) NULL,\n',
            '  display_order INT NULL,\n',
            '  is_active TINYINT(1) NOT NULL DEFAULT 1,\n',
            '  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n',
            '  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n',
            '  PRIMARY KEY (id),\n',
            '  KEY idx_main_active (is_active),\n',
            '  KEY idx_main_order (display_order)\n',
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

-- sub_categories
SET
    @tbl_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'sub_categories'
    );

SET
    @ddl := IF(
        @tbl_exists = 0,
        CONCAT(
            'CREATE TABLE sub_categories (\n',
            '  id ',
            @cat_col_type,
            ' NOT NULL,\n',
            '  main_category_id ',
            @cat_col_type,
            ' NOT NULL,\n',
            '  name VARCHAR(255) NOT NULL,\n',
            '  description TEXT NULL,\n',
            '  image_url VARCHAR(1024) NULL,\n',
            '  display_order INT NULL,\n',
            '  is_active TINYINT(1) NOT NULL DEFAULT 1,\n',
            '  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n',
            '  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n',
            '  PRIMARY KEY (id),\n',
            '  KEY idx_sub_main (main_category_id),\n',
            '  KEY idx_sub_active (is_active),\n',
            '  CONSTRAINT fk_sub_main FOREIGN KEY (main_category_id) REFERENCES main_categories(id) ON DELETE CASCADE\n',
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