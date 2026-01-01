-- Table to track which messages each user has read in each chat
CREATE TABLE IF NOT EXISTS chat_read_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    last_read_message_id BIGINT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_chat_user (chat_id, user_id),
    INDEX idx_chat (chat_id),
    INDEX idx_user (user_id),
    INDEX idx_last_read_message (last_read_message_id),
    FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE,
    FOREIGN KEY (last_read_message_id) REFERENCES messages (id) ON DELETE CASCADE
);