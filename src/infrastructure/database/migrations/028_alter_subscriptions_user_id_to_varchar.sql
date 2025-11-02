-- Align subscriptions.user_id with auth token id type (string/UUID)

ALTER TABLE subscriptions
MODIFY COLUMN user_id VARCHAR(64) NOT NULL,
DROP INDEX idx_user,
ADD INDEX idx_user (user_id);