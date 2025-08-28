-- Tables to store saved products and saved suppliers (businesses)

CREATE TABLE IF NOT EXISTS saved_products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    product_id VARCHAR(36) NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_user_product (user_id, product_id),
    INDEX idx_saved_products_user (user_id),
    INDEX idx_saved_products_product (product_id)
);

CREATE TABLE IF NOT EXISTS saved_suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    supplier_id VARCHAR(36) NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_user_supplier (user_id, supplier_id),
    INDEX idx_saved_suppliers_user (user_id),
    INDEX idx_saved_suppliers_supplier (supplier_id)
);