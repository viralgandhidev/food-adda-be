-- Chats table to store conversations between users and suppliers
CREATE TABLE IF NOT EXISTS chats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    supplier_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_user_supplier (user_id, supplier_id),
    INDEX idx_user (user_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_updated_at (updated_at)
);

-- Messages table to store chat messages
CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    sender_id VARCHAR(36) NOT NULL,
    message_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_chat (chat_id),
    INDEX idx_sender (sender_id),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
);

