-- Align form_submissions.user_id type with users.id (string/UUID or numeric) (idempotent)
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND COLUMN_NAME = 'user_id';

SET @sql = IF(
    @col_exists > 0,
    'ALTER TABLE form_submissions MODIFY COLUMN user_id VARCHAR(64) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
