-- Store uploaded files associated with a form submission

CREATE TABLE IF NOT EXISTS form_submission_files (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    submission_id BIGINT NOT NULL,
    field_name VARCHAR(128) NOT NULL,
    file_path VARCHAR(512) NOT NULL,
    original_name VARCHAR(255) NULL,
    mime_type VARCHAR(128) NULL,
    size BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_submission (submission_id)
);