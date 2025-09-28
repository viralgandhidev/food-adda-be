-- Make user_type nullable and default to 'CONSUMER'
ALTER TABLE users
MODIFY COLUMN user_type VARCHAR(32) NULL DEFAULT 'CONSUMER';