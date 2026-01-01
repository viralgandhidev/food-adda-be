-- Align subscriptions.user_id with auth token id type (string/UUID) (idempotent)

-- Check if column exists before modifying
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'subscriptions'
  AND COLUMN_NAME = 'user_id';

SET @sql = IF(
    @col_exists > 0,
    'ALTER TABLE subscriptions MODIFY COLUMN user_id VARCHAR(64) NOT NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop index if exists
SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'subscriptions'
  AND INDEX_NAME = 'idx_user';

SET @sql = IF(
    @idx_exists > 0,
    'ALTER TABLE subscriptions DROP INDEX idx_user',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index if not exists
SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'subscriptions'
  AND INDEX_NAME = 'idx_user';

SET @sql = IF(
    @idx_exists = 0,
    'ALTER TABLE subscriptions ADD INDEX idx_user (user_id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
