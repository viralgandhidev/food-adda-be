-- Add attachment support to messages table
ALTER TABLE messages
ADD COLUMN attachment_url VARCHAR(500) NULL,
ADD COLUMN attachment_type VARCHAR(50) NULL COMMENT 'image, file, voice';

