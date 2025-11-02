-- Subscriptions table to track plan purchase and Razorpay payment

CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    plan_code VARCHAR(32) NOT NULL, -- e.g., SILVER, GOLD
    plan_label VARCHAR(64) NOT NULL, -- display name
    amount_paise INT NOT NULL, -- amount in paise for Razorpay
    currency VARCHAR(8) NOT NULL DEFAULT 'INR',
    status ENUM(
        'INITIATED',
        'PENDING_PAYMENT',
        'PAID',
        'ACTIVE',
        'CANCELLED',
        'FAILED'
    ) NOT NULL DEFAULT 'INITIATED',
    razorpay_order_id VARCHAR(128) NULL,
    razorpay_payment_id VARCHAR(128) NULL,
    razorpay_signature VARCHAR(256) NULL,
    receipt VARCHAR(64) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_order (razorpay_order_id)
);