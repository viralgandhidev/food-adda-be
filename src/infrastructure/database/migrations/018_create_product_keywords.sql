-- Create product_keywords join table (product ↔ keywords many-to-many)

-- Mirror categories.id type for product_id and keywords.id type for keyword_id
SET
    @id_col_type := (
        SELECT COLUMN_TYPE
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'products'
            AND COLUMN_NAME = 'id'
        LIMIT 1
    );

SET
    @kw_id_col_type := (
        SELECT COLUMN_TYPE
        FROM information_schema.COLUMNS
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'keywords'
            AND COLUMN_NAME = 'id'
        LIMIT 1
    );

SET
    @tbl_exists := (
        SELECT COUNT(*)
        FROM information_schema.TABLES
        WHERE
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'product_keywords'
    );

SET
    @ddl := IF(
        @tbl_exists = 0,
        CONCAT(
            'CREATE TABLE product_keywords (\n',
            '  product_id ',
            @id_col_type,
            ' NOT NULL,\n',
            '  keyword_id ',
            @kw_id_col_type,
            ' NOT NULL,\n',
            '  PRIMARY KEY (product_id, keyword_id),\n',
            '  KEY idx_pk_keyword (keyword_id),\n',
            '  CONSTRAINT fk_pk_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,\n',
            '  CONSTRAINT fk_pk_keyword FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE\n',
            ') ENGINE=InnoDB'
        ),
        'SELECT 1'
    );

PREPARE stmt FROM @ddl;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;