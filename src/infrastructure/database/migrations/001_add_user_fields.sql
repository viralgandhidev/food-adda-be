-- Add new columns to users table (idempotent - check if columns exist first)
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'users'
  AND COLUMN_NAME = 'company_name';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE users ADD COLUMN company_name VARCHAR(255) AFTER address',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'users'
  AND COLUMN_NAME = 'company_description';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE users ADD COLUMN company_description TEXT AFTER company_name',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index for better performance (idempotent - check if index exists first)
SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'users'
  AND INDEX_NAME = 'idx_users_company_name';

SET @sql = IF(
    @idx_exists = 0,
    'CREATE INDEX idx_users_company_name ON users (company_name)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;