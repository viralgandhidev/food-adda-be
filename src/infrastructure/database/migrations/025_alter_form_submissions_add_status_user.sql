-- Link form submissions to users and add approval status (idempotent)

-- Add user_id column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND COLUMN_NAME = 'user_id';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE form_submissions ADD COLUMN user_id BIGINT NULL AFTER contact_phone',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add status column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND COLUMN_NAME = 'status';

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE form_submissions ADD COLUMN status ENUM(''SUBMITTED'', ''APPROVED'', ''REJECTED'') NOT NULL DEFAULT ''SUBMITTED'' AFTER user_id',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index idx_user_form
SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND INDEX_NAME = 'idx_user_form';

SET @sql = IF(
    @idx_exists = 0,
    'ALTER TABLE form_submissions ADD INDEX idx_user_form (user_id, form_type)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index idx_status
SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'form_submissions'
  AND INDEX_NAME = 'idx_status';

SET @sql = IF(
    @idx_exists = 0,
    'ALTER TABLE form_submissions ADD INDEX idx_status (status)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Optional FK (skip if users table type differs)
-- ALTER TABLE form_submissions
--     ADD CONSTRAINT fk_form_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE;
