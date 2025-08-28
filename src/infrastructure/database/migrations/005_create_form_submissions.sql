-- Generic form submissions table to support multiple sector forms

CREATE TABLE IF NOT EXISTS form_submissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    form_type ENUM(
        'B2B',
        'B2C',
        'HORECA',
        'FRANCHISE',
        'RECRUITMENT',
        'QUOTE_REQUEST'
    ) NOT NULL,
    contact_name VARCHAR(255) NULL,
    contact_email VARCHAR(255) NULL,
    contact_phone VARCHAR(64) NULL,
    payload JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_form_type (form_type),
    INDEX idx_created_at (created_at)
);