-- Add attachment support to messages table (idempotent)
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'messages'
  AND COLUMN_NAME = 'attachment_url';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE messages ADD COLUMN attachment_url VARCHAR(500) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'messages'
  AND COLUMN_NAME = 'attachment_type';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE messages ADD COLUMN attachment_type VARCHAR(50) NULL COMMENT ''image, file, voice''',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
