-- MySQL-safe migration to enforce one view per viewer per day
-- Compatible with existing data and repeatable runs

-- 1) PROFILE VIEWS: add view_date if missing (MySQL-safe via dynamic SQL)
SET
    @col_exists := (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'profile_views'
            AND COLUMN_NAME = 'view_date'
    );

SET
    @ddl := IF(
        @col_exists = 0,
        'ALTER TABLE profile_views ADD COLUMN view_date DATE NULL AFTER viewer_id',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Backfill view_date from viewed_at (disable safe updates temporarily)
SET @OLD_SQL_SAFE_UPDATES = @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

UPDATE profile_views
SET
    view_date = DATE(viewed_at)
WHERE
    view_date IS NULL;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;

-- Remove duplicates (keep earliest id per supplier/viewer/view_date)
SET @OLD_SQL_SAFE_UPDATES_DUP1 = @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

DELETE pv1
FROM
    profile_views pv1
    JOIN profile_views pv2 ON pv1.supplier_id = pv2.supplier_id
    AND pv1.viewer_id = pv2.viewer_id
    AND pv1.view_date = pv2.view_date
    AND pv1.id > pv2.id;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES_DUP1;

-- Enforce NOT NULL (no default needed; inserts supply CURRENT_DATE)
ALTER TABLE profile_views MODIFY view_date DATE NOT NULL;

-- Create unique index if missing (MySQL-safe via dynamic SQL)
SET
    @idx_exists := (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'profile_views'
            AND INDEX_NAME = 'uniq_profile_daily'
    );

SET
    @ddl := IF(
        @idx_exists = 0,
        'CREATE UNIQUE INDEX uniq_profile_daily ON profile_views (supplier_id, viewer_id, view_date)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- 2) PRODUCT VIEWS: add view_date if missing
SET
    @col_exists := (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'product_views'
            AND COLUMN_NAME = 'view_date'
    );

SET
    @ddl := IF(
        @col_exists = 0,
        'ALTER TABLE product_views ADD COLUMN view_date DATE NULL AFTER viewer_id',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- Backfill
SET @OLD_SQL_SAFE_UPDATES = @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

UPDATE product_views
SET
    view_date = DATE(viewed_at)
WHERE
    view_date IS NULL;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;

-- Remove duplicates (keep earliest id per product/viewer/view_date)
SET @OLD_SQL_SAFE_UPDATES_DUP2 = @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

DELETE pv1
FROM
    product_views pv1
    JOIN product_views pv2 ON pv1.product_id = pv2.product_id
    AND pv1.viewer_id = pv2.viewer_id
    AND pv1.view_date = pv2.view_date
    AND pv1.id > pv2.id;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES_DUP2;

-- Enforce NOT NULL
ALTER TABLE product_views MODIFY view_date DATE NOT NULL;

-- Create unique index if missing
SET
    @idx_exists := (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'product_views'
            AND INDEX_NAME = 'uniq_product_daily'
    );

SET
    @ddl := IF(
        @idx_exists = 0,
        'CREATE UNIQUE INDEX uniq_product_daily ON product_views (product_id, viewer_id, view_date)',
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;