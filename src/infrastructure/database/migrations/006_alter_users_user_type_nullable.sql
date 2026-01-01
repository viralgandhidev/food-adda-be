-- Make user_type nullable and default to 'CONSUMER' (idempotent - check if column exists first)
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'users'
  AND COLUMN_NAME = 'user_type';

SET @sql = IF(
    @col_exists > 0,
    'ALTER TABLE users MODIFY COLUMN user_type VARCHAR(32) NULL DEFAULT ''CONSUMER''',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
