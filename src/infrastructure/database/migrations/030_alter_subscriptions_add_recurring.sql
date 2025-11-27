SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'razorpay_subscription_id'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN razorpay_subscription_id VARCHAR(64) NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'razorpay_customer_id'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN razorpay_customer_id VARCHAR(64) NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'auth_payment_id'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN auth_payment_id VARCHAR(64) NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'current_period_start'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN current_period_start DATETIME NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'current_period_end'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN current_period_end DATETIME NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'next_charge_at'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN next_charge_at DATETIME NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'total_count'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN total_count INT NULL',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'paid_count'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN paid_count INT NOT NULL DEFAULT 0',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;

SET
    @stmt := IF(
        (
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'subscriptions'
                AND COLUMN_NAME = 'cancel_at_period_end'
        ) = 0,
        'ALTER TABLE subscriptions ADD COLUMN cancel_at_period_end TINYINT(1) NOT NULL DEFAULT 0',
        'SELECT 1'
    );

PREPARE alter_stmt FROM @stmt;

EXECUTE alter_stmt;

DEALLOCATE PREPARE alter_stmt;