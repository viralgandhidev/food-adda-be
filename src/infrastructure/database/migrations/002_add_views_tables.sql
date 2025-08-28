-- Profile and Product views tracking tables

CREATE TABLE IF NOT EXISTS profile_views (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id VARCHAR(36) NOT NULL,
    viewer_id VARCHAR(36) NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_profile_views_supplier (supplier_id),
    INDEX idx_profile_views_viewer (viewer_id)
);

CREATE TABLE IF NOT EXISTS product_views (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(36) NOT NULL,
    viewer_id VARCHAR(36) NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_views_product (product_id),
    INDEX idx_product_views_viewer (viewer_id)
);