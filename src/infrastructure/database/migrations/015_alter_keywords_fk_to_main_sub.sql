-- Update keywords FKs to reference main_categories/sub_categories instead of categories

-- Drop existing FKs if present
SET
    @fk_main_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'keywords'
            AND CONSTRAINT_NAME = 'fk_keywords_main'
    );

SET
    @ddl := IF(
        @fk_main_exists > 0,
        'ALTER TABLE keywords DROP FOREIGN KEY fk_keywords_main',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SET
    @fk_sub_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'keywords'
            AND CONSTRAINT_NAME = 'fk_keywords_sub'
    );

SET
    @ddl := IF(
        @fk_sub_exists > 0,
        'ALTER TABLE keywords DROP FOREIGN KEY fk_keywords_sub',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Ensure column types match main/sub ids (mirror categories.id)
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
        'ALTER TABLE keywords 
  MODIFY main_category_id ',
        @cat_col_type,
        ' NOT NULL, 
  MODIFY sub_category_id ',
        @cat_col_type,
        ' NULL'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Add new FKs
ALTER TABLE keywords
ADD CONSTRAINT fk_keywords_main FOREIGN KEY (main_category_id) REFERENCES main_categories (id) ON DELETE CASCADE,
ADD CONSTRAINT fk_keywords_sub FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id) ON DELETE SET NULL;