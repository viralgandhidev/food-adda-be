-- Make form_submissions.form_type flexible to support new sub-types (idempotent)
-- Safe to run multiple times (re-applying same definition is a no-op in practice)
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND COLUMN_NAME = 'form_type';

SET @sql = IF(
    @col_exists > 0,
    'ALTER TABLE form_submissions MODIFY COLUMN form_type VARCHAR(32) NOT NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
