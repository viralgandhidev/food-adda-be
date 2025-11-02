-- Link form submissions to users and add approval status

ALTER TABLE form_submissions
ADD COLUMN user_id BIGINT NULL AFTER contact_phone,
ADD COLUMN status ENUM(
    'SUBMITTED',
    'APPROVED',
    'REJECTED'
) NOT NULL DEFAULT 'SUBMITTED' AFTER user_id,
ADD INDEX idx_user_form (user_id, form_type),
ADD INDEX idx_status (status);

-- Optional FK (skip if users table type differs)
-- ALTER TABLE form_submissions
--     ADD CONSTRAINT fk_form_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE;