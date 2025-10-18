-- Seed main and sub categories based on provided list
-- Assumes categories(id CHAR(36) PK, name VARCHAR(255), description TEXT NULL,
--   parent_id CHAR(36) NULL, is_active TINYINT(1) NOT NULL DEFAULT 1,
--   display_order INT NULL)

-- Helper: generate ID if not exists
-- Note: Using UUID() for IDs; adjust if your schema uses different type

-- Main Category: Fresh Produce
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Fresh Produce', NULL, 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    );

-- Subcategories for Fresh Produce
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Fruits', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Fruits'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Domestic', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fruits'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Domestic'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fruits'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Imported', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fruits'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Imported'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fruits'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Seasonal & Exotic', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fruits'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Seasonal & Exotic'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fruits'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Vegetables', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Vegetables'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Root Vegetables', (
        SELECT id
        FROM categories
        WHERE
            name = 'Vegetables'
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Root Vegetables'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Vegetables'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Leafy Greens', (
        SELECT id
        FROM categories
        WHERE
            name = 'Vegetables'
    ), 1, 7
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Leafy Greens'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Vegetables'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Exotic Veggies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Vegetables'
    ), 1, 8
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Exotic Veggies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Vegetables'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Herbs & Spices (Fresh)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    ), 1, 9
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Herbs & Spices (Fresh)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Organic Produce', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    ), 1, 10
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Organic Produce'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Pre-cut & Packaged Produce', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    ), 1, 11
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Pre-cut & Packaged Produce'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

-- NOTE: Expanded full list per provided structure

-- Main Category: Grains, Pulses & Cereals
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Grains, Pulses & Cereals', NULL, 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    );

-- Sub: Rice (and children)
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Rice', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Rice'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Basmati', (
        SELECT id
        FROM categories
        WHERE
            name = 'Rice'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Basmati'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Rice'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Non-Basmati', (
        SELECT id
        FROM categories
        WHERE
            name = 'Rice'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Non-Basmati'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Rice'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Parboiled', (
        SELECT id
        FROM categories
        WHERE
            name = 'Rice'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Parboiled'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Rice'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Organic', (
        SELECT id
        FROM categories
        WHERE
            name = 'Rice'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Organic'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Rice'
            )
    );

-- Sub: Wheat & Products (children)
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Wheat & Products', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Wheat & Products'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Whole Wheat (Atta)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Wheat & Products'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Whole Wheat (Atta)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Wheat & Products'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Refined Flour (Maida, Sooji)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Wheat & Products'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Refined Flour (Maida, Sooji)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Wheat & Products'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bran & Byproducts', (
        SELECT id
        FROM categories
        WHERE
            name = 'Wheat & Products'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bran & Byproducts'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Wheat & Products'
            )
    );

-- Sub: Pulses & Lentils; Millets & Ancient Grains; Corn & Maize Products
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Pulses & Lentils', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Pulses & Lentils'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Millets & Ancient Grains', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Millets & Ancient Grains'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Corn & Maize Products', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Corn & Maize Products'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Dairy & Dairy Alternatives
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Dairy & Dairy Alternatives', NULL, 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Milk & Cream', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Milk & Cream'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Butter, Ghee & Paneer', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Butter, Ghee & Paneer'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Yogurt, Curd & Lassi', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Yogurt, Curd & Lassi'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Cheese (Processed, Artisan, Specialty)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Cheese (Processed, Artisan, Specialty)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Dairy Ingredients (Milk Powder, Whey, Casein)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Dairy Ingredients (Milk Powder, Whey, Casein)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Plant-based Dairy (Soy, Almond, Oat, Coconut)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Plant-based Dairy (Soy, Almond, Oat, Coconut)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Meat, Poultry & Seafood
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Meat, Poultry & Seafood', NULL, 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    );
-- children under Meat, Poultry & Seafood
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Fresh Meat', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Fresh Meat'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Mutton, Pork, Beef', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Mutton, Pork, Beef'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Poultry', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Poultry'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chicken, Duck, Turkey', (
        SELECT id
        FROM categories
        WHERE
            name = 'Poultry'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chicken, Duck, Turkey'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Poultry'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Eggs & Egg Products', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Eggs & Egg Products'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Seafood', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Seafood'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Fresh Fish', (
        SELECT id
        FROM categories
        WHERE
            name = 'Seafood'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Fresh Fish'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Seafood'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Fish', (
        SELECT id
        FROM categories
        WHERE
            name = 'Seafood'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Fish'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Seafood'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Shellfish (Shrimp, Crab, Lobster)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Seafood'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Shellfish (Shrimp, Crab, Lobster)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Seafood'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Processed Meat & Seafood (Nuggets, Sausages, Kebabs)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Processed Meat & Seafood (Nuggets, Sausages, Kebabs)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Beverages
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Beverages', NULL, 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Water & Mineral Water', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Water & Mineral Water'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Juices & Fruit Beverages', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Juices & Fruit Beverages'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Carbonated Drinks & Energy Drinks', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Carbonated Drinks & Energy Drinks'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );
-- Tea
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Tea', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Tea'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Black Tea', (
        SELECT id
        FROM categories
        WHERE
            name = 'Tea'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Black Tea'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Tea'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Green Tea', (
        SELECT id
        FROM categories
        WHERE
            name = 'Tea'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Green Tea'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Tea'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Herbal & Specialty Tea', (
        SELECT id
        FROM categories
        WHERE
            name = 'Tea'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Herbal & Specialty Tea'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Tea'
            )
    );
-- Coffee
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Coffee', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Coffee'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Roasted Beans', (
        SELECT id
        FROM categories
        WHERE
            name = 'Coffee'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Roasted Beans'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Coffee'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ground Coffee', (
        SELECT id
        FROM categories
        WHERE
            name = 'Coffee'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ground Coffee'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Coffee'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Instant Coffee', (
        SELECT id
        FROM categories
        WHERE
            name = 'Coffee'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Instant Coffee'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Coffee'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Alcoholic Beverages', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Alcoholic Beverages'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Oils, Fats & Spices
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Oils, Fats & Spices', NULL, 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Edible Oils', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Edible Oils'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sunflower, Groundnut, Mustard, Olive, Palm', (
        SELECT id
        FROM categories
        WHERE
            name = 'Edible Oils'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sunflower, Groundnut, Mustard, Olive, Palm'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Edible Oils'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ghee, Vanaspati & Margarine', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ghee, Vanaspati & Margarine'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Whole Spices', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Whole Spices'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ground Spices', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ground Spices'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Blended Masalas & Seasonings', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Blended Masalas & Seasonings'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Pickles, Chutneys & Sauces', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Pickles, Chutneys & Sauces'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Bakery, Confectionery & Snacks
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bakery, Confectionery & Snacks', NULL, 1, 7
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bakery', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bakery'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bread, Buns, Rolls', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bread, Buns, Rolls'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Cakes, Pastries, Muffins', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Cakes, Pastries, Muffins'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Biscuits & Cookies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Biscuits & Cookies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chocolates & Candies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chocolates & Candies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Indian Snacks (Namkeen, Farsan, Bhujia)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Indian Snacks (Namkeen, Farsan, Bhujia)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chips, Extruded Snacks & Popcorn', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chips, Extruded Snacks & Popcorn'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Breakfast Cereals & Granola', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Breakfast Cereals & Granola'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Packaged & Processed Foods
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Packaged & Processed Foods', NULL, 1, 8
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ready-to-Eat Meals', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ready-to-Eat Meals'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ready-to-Cook Meals', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ready-to-Cook Meals'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Instant Foods (Noodles, Pasta, Soups)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Instant Foods (Noodles, Pasta, Soups)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Vegetables', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Vegetables'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Snacks (Parathas, Samosas, Patties)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Snacks (Parathas, Samosas, Patties)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Canned & Jarred Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 7
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Canned & Jarred Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Nutritional & Functional Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged & Processed Foods'
            AND parent_id IS NULL
    ), 1, 8
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Nutritional & Functional Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged & Processed Foods'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Health, Organic & Specialty Foods
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Health, Organic & Specialty Foods', NULL, 1, 9
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Organic Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Organic Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Gluten-Free Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Gluten-Free Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Vegan & Plant-based Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Vegan & Plant-based Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Keto, Low-Carb, Sugar-Free Foods', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Keto, Low-Carb, Sugar-Free Foods'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Superfoods (Chia, Flax, Spirulina, Moringa)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Superfoods (Chia, Flax, Spirulina, Moringa)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ayurvedic & Herbal Products', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ayurvedic & Herbal Products'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Nutraceuticals & Health Supplements', (
        SELECT id
        FROM categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
            AND parent_id IS NULL
    ), 1, 7
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Nutraceuticals & Health Supplements'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Food Ingredients & Additives
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Ingredients & Additives', NULL, 1, 10
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Flours & Starches', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Flours & Starches'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Ingredients & Additives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sweeteners (Sugar, Jaggery, Honey, Stevia)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sweeteners (Sugar, Jaggery, Honey, Stevia)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Ingredients & Additives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Colours, Flavors & Extracts', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Colours, Flavors & Extracts'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Ingredients & Additives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Preservatives, Stabilizers & Emulsifiers', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Preservatives, Stabilizers & Emulsifiers'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Ingredients & Additives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Baking Ingredients (Yeast, Cocoa, Chocolate, Vanilla)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Ingredients & Additives'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Baking Ingredients (Yeast, Cocoa, Chocolate, Vanilla)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Ingredients & Additives'
                    AND parent_id IS NULL
            )
    );

-- Main Category: HoReCa & Institutional Supplies
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'HoReCa & Institutional Supplies', NULL, 1, 11
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bulk Grains, Pulses & Oils', (
        SELECT id
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bulk Grains, Pulses & Oils'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bulk Dairy & Meat Products', (
        SELECT id
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bulk Dairy & Meat Products'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sauces, Dressings & Marinades (Bulk)', (
        SELECT id
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sauces, Dressings & Marinades (Bulk)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ready Mixes for Hotels & Caterers', (
        SELECT id
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ready Mixes for Hotels & Caterers'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Bulk Supplies for HoReCa', (
        SELECT id
        FROM categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Bulk Supplies for HoReCa'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Packaging & Allied Products
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Packaging & Allied Products', NULL, 1, 12
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Packaging', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Packaging'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Boxes, Trays, Pouches, Cans, Bottles', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Boxes, Trays, Pouches, Cans, Bottles'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Eco-friendly Packaging (Biodegradable, Compostable)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Eco-friendly Packaging (Biodegradable, Compostable)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Labels, Stickers & Barcodes', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Labels, Stickers & Barcodes'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Storage Containers & Utensils', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Storage Containers & Utensils'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Industrial Packaging Solutions', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaging & Allied Products'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Industrial Packaging Solutions'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaging & Allied Products'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Cold Chain & Logistics
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Cold Chain & Logistics', NULL, 1, 13
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Cold Storage Services', (
        SELECT id
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Cold Storage Services'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Cold Chain & Logistics'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Refrigerated Transport', (
        SELECT id
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Refrigerated Transport'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Cold Chain & Logistics'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Warehousing Solutions', (
        SELECT id
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Warehousing Solutions'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Cold Chain & Logistics'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Supply Chain Management Tools', (
        SELECT id
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Supply Chain Management Tools'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Cold Chain & Logistics'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Logistics solutions', (
        SELECT id
        FROM categories
        WHERE
            name = 'Cold Chain & Logistics'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Logistics solutions'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Cold Chain & Logistics'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Food Processing & Machinery
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Processing & Machinery', NULL, 1, 14
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Processing Equipment', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Processing Equipment'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Dairy Processing Machinery', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Dairy Processing Machinery'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Meat & Seafood Processing Machines', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Meat & Seafood Processing Machines'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Beverage Processing Units', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Beverage Processing Units'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bakery & Confectionery Equipment', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bakery & Confectionery Equipment'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Commercial Kitchen Equipment', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Processing & Machinery'
            AND parent_id IS NULL
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Commercial Kitchen Equipment'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Processing & Machinery'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Agri & Farm Supplies
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Agri & Farm Supplies', NULL, 1, 15
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Seeds, Fertilizers & Pesticides', (
        SELECT id
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Seeds, Fertilizers & Pesticides'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Agri & Farm Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Agri-Tech & Smart Farming Tools', (
        SELECT id
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Agri-Tech & Smart Farming Tools'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Agri & Farm Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Animal Feed & Nutrition', (
        SELECT id
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Animal Feed & Nutrition'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Agri & Farm Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Aquaculture & Fishery Supplies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Aquaculture & Fishery Supplies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Agri & Farm Supplies'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Hydroponics & Vertical Farming Inputs', (
        SELECT id
        FROM categories
        WHERE
            name = 'Agri & Farm Supplies'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Hydroponics & Vertical Farming Inputs'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Agri & Farm Supplies'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Indian Snacks & Sweets
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Indian Snacks & Sweets', NULL, 1, 16
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Indian Snacks & Sweets'
            AND parent_id IS NULL
    );
-- Subgroups A/B/C/D
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Indian Snacks (Savory)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks & Sweets'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks & Sweets'
                    AND parent_id IS NULL
            )
    );
-- Items under Indian Snacks (Savory)
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Namkeen & Mixtures', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Namkeen & Mixtures'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Bhujia', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Bhujia'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chivda / Poha Mix', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chivda / Poha Mix'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sev (Plain, Masala, Garlic, Nylon)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sev (Plain, Masala, Garlic, Nylon)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Regional Mixtures (South Indian, Bombay, North Indian)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Regional Mixtures (South Indian, Bombay, North Indian)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Farsan & Regional Snacks', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 6
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Farsan & Regional Snacks'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Kachori, Samosa, Mathri', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 7
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Kachori, Samosa, Mathri'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chakli / Murukku', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 8
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chakli / Murukku'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Banana Chips, Tapioca Chips', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 9
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Banana Chips, Tapioca Chips'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Khakhra & Papad', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 10
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Khakhra & Papad'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Roasted & Baked Snacks', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 11
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Roasted & Baked Snacks'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Roasted Chana / Peanuts', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 12
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Roasted Chana / Peanuts'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Makhana (Fox Nuts)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 13
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Makhana (Fox Nuts)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Baked Mathri / Khakhra', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 14
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Baked Mathri / Khakhra'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Extruded Snacks & Chips', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 15
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Extruded Snacks & Chips'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Potato Chips', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 16
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Potato Chips'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Kurkure-style Extruded Snacks', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 17
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Kurkure-style Extruded Snacks'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Popcorn', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks (Savory)'
    ), 1, 18
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Popcorn'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks (Savory)'
            )
    );

-- Indian Sweets (Mithai & Desserts)
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Indian Sweets (Mithai & Desserts)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks & Sweets'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Indian Sweets (Mithai & Desserts)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks & Sweets'
                    AND parent_id IS NULL
            )
    );
-- sub items under Indian Sweets
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Traditional Sweets', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Sweets (Mithai & Desserts)'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Traditional Sweets'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Sweets (Mithai & Desserts)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Ladoo (Besan, Motichoor, Coconut, Boondi, Til)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Traditional Sweets'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Ladoo (Besan, Motichoor, Coconut, Boondi, Til)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Traditional Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Barfi (Kaju Katli, Coconut, Besan, Badam, Chocolate)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Traditional Sweets'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Barfi (Kaju Katli, Coconut, Besan, Badam, Chocolate)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Traditional Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Halwa (Sooji, Moong Dal, Gajar, Karachi Halwa)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Traditional Sweets'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Halwa (Sooji, Moong Dal, Gajar, Karachi Halwa)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Traditional Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Milk-based Sweets', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Sweets (Mithai & Desserts)'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Milk-based Sweets'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Sweets (Mithai & Desserts)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Rasgulla, Gulab Jamun, Cham Cham', (
        SELECT id
        FROM categories
        WHERE
            name = 'Milk-based Sweets'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Rasgulla, Gulab Jamun, Cham Cham'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Milk-based Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Rasmalai, Malai Sandwich', (
        SELECT id
        FROM categories
        WHERE
            name = 'Milk-based Sweets'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Rasmalai, Malai Sandwich'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Milk-based Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Kalakand, Milk Cake, Peda', (
        SELECT id
        FROM categories
        WHERE
            name = 'Milk-based Sweets'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Kalakand, Milk Cake, Peda'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Milk-based Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Regional Specialties', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Sweets (Mithai & Desserts)'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Regional Specialties'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Sweets (Mithai & Desserts)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Mysore Pak, Dharwad Peda, Sandesh, Mishti Doi', (
        SELECT id
        FROM categories
        WHERE
            name = 'Regional Specialties'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Mysore Pak, Dharwad Peda, Sandesh, Mishti Doi'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Regional Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Petha, Ghevar, Balushahi', (
        SELECT id
        FROM categories
        WHERE
            name = 'Regional Specialties'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Petha, Ghevar, Balushahi'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Regional Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Modak, Kozhukattai, Poli', (
        SELECT id
        FROM categories
        WHERE
            name = 'Regional Specialties'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Modak, Kozhukattai, Poli'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Regional Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Modern & Fusion Sweets', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Sweets (Mithai & Desserts)'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Modern & Fusion Sweets'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Sweets (Mithai & Desserts)'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Dry Fruit Rolls', (
        SELECT id
        FROM categories
        WHERE
            name = 'Modern & Fusion Sweets'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Dry Fruit Rolls'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Modern & Fusion Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Chocolate-dipped Mithai', (
        SELECT id
        FROM categories
        WHERE
            name = 'Modern & Fusion Sweets'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Chocolate-dipped Mithai'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Modern & Fusion Sweets'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sugar-free / Low-calorie Sweets', (
        SELECT id
        FROM categories
        WHERE
            name = 'Modern & Fusion Sweets'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sugar-free / Low-calorie Sweets'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Modern & Fusion Sweets'
            )
    );

-- Festive & Seasonal Specialties
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Festive & Seasonal Specialties', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks & Sweets'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks & Sweets'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Diwali Specials (Soan Papdi, Kaju Katli, Mix Mithai Boxes)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Diwali Specials (Soan Papdi, Kaju Katli, Mix Mithai Boxes)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Festive & Seasonal Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Holi Specials (Gujiya, Malpua, Thandai Mix)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Holi Specials (Gujiya, Malpua, Thandai Mix)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Festive & Seasonal Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Raksha Bandhan (Gift Packs, Premium Dry Fruit Mithai)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Raksha Bandhan (Gift Packs, Premium Dry Fruit Mithai)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Festive & Seasonal Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Eid Specials (Sheer Khurma Mix, Sewai, Baklava)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Eid Specials (Sheer Khurma Mix, Sewai, Baklava)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Festive & Seasonal Specialties'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Christmas Specials (Plum Cake, Dry Fruit Cake)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Festive & Seasonal Specialties'
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Christmas Specials (Plum Cake, Dry Fruit Cake)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Festive & Seasonal Specialties'
            )
    );

-- Packaged Indian Sweets & Snacks
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Packaged Indian Sweets & Snacks', (
        SELECT id
        FROM categories
        WHERE
            name = 'Indian Snacks & Sweets'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Packaged Indian Sweets & Snacks'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Indian Snacks & Sweets'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Vacuum-packed Mithai (long shelf life)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged Indian Sweets & Snacks'
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Vacuum-packed Mithai (long shelf life)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged Indian Sweets & Snacks'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Frozen Snacks (Samosa, Kachori, Patties)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged Indian Sweets & Snacks'
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Frozen Snacks (Samosa, Kachori, Patties)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged Indian Sweets & Snacks'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Sweet Gift Hampers (Corporate, Wedding, Festive)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged Indian Sweets & Snacks'
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Sweet Gift Hampers (Corporate, Wedding, Festive)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged Indian Sweets & Snacks'
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Namkeen Gift Packs', (
        SELECT id
        FROM categories
        WHERE
            name = 'Packaged Indian Sweets & Snacks'
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Namkeen Gift Packs'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Packaged Indian Sweets & Snacks'
            )
    );

-- Main Category: Food Testing & Certification
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Testing & Certification', NULL, 1, 17
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Testing Labs (FSSAI-approved)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Testing Labs (FSSAI-approved)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Testing & Certification'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Quality Certification Agencies (ISO, HACCP, BRC, Halal, Organic)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Quality Certification Agencies (ISO, HACCP, BRC, Halal, Organic)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Testing & Certification'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Safety & Hygiene Auditors', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Safety & Hygiene Auditors'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Testing & Certification'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Nutritional Analysis Labs', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Nutritional Analysis Labs'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Testing & Certification'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Microbiology & Shelf-life Testing', (
        SELECT id
        FROM categories
        WHERE
            name = 'Food Testing & Certification'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Microbiology & Shelf-life Testing'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Food Testing & Certification'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Branding, Marketing & Design
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Branding, Marketing & Design', NULL, 1, 18
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Branding & Creative Agencies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Branding & Creative Agencies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Branding, Marketing & Design'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Packaging Design Services', (
        SELECT id
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Packaging Design Services'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Branding, Marketing & Design'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Photography & Videography', (
        SELECT id
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Photography & Videography'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Branding, Marketing & Design'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Digital Marketing Agencies (SEO, Social Media, Ads)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Digital Marketing Agencies (SEO, Social Media, Ads)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Branding, Marketing & Design'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Trade Show & Event Management for Food', (
        SELECT id
        FROM categories
        WHERE
            name = 'Branding, Marketing & Design'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Trade Show & Event Management for Food'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Branding, Marketing & Design'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Consultancy & Advisory Services
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Consultancy & Advisory Services', NULL, 1, 19
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Industry Consultants (Product Development, Scale-up)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Industry Consultants (Product Development, Scale-up)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Legal & Regulatory Consultants (FSSAI, Labeling, Import-Export)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Legal & Regulatory Consultants (FSSAI, Labeling, Import-Export)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Export-Import Consultants (APEDA, DGFT, Customs)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Export-Import Consultants (APEDA, DGFT, Customs)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Supply Chain & Logistics Consultants', (
        SELECT id
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Supply Chain & Logistics Consultants'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'HoReCa Consulting (Menu Engineering, Kitchen Setup)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Consultancy & Advisory Services'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'HoReCa Consulting (Menu Engineering, Kitchen Setup)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Infrastructure & Turnkey Solutions
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Infrastructure & Turnkey Solutions', NULL, 1, 20
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Cold Storage & Warehouse Developers', (
        SELECT id
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Cold Storage & Warehouse Developers'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Park / Industrial Park Developers', (
        SELECT id
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Park / Industrial Park Developers'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Turnkey Food Processing Plant Setup Companies', (
        SELECT id
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Turnkey Food Processing Plant Setup Companies'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Commercial Kitchen Setup & AMC Services', (
        SELECT id
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Commercial Kitchen Setup & AMC Services'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Packaging & Machinery Integrators', (
        SELECT id
        FROM categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Packaging & Machinery Integrators'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Training, Skill Development & Manpower
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Training, Skill Development & Manpower', NULL, 1, 21
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Technology Training Institutes', (
        SELECT id
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Technology Training Institutes'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Culinary Schools & HoReCa Training', (
        SELECT id
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Culinary Schools & HoReCa Training'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Skill Development Agencies (NSDC, Sector Skill Councils)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Skill Development Agencies (NSDC, Sector Skill Councils)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Blue-collar Manpower Agencies (Chefs, Workers, Packers)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Blue-collar Manpower Agencies (Chefs, Workers, Packers)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'HR & Staffing Agencies (for Food Industry)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Training, Skill Development & Manpower'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'HR & Staffing Agencies (for Food Industry)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                    AND parent_id IS NULL
            )
    );

-- Main Category: Finance, Insurance & Legal Support
INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Finance, Insurance & Legal Support', NULL, 1, 22
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Food Business Loans & NBFCs', (
        SELECT id
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    ), 1, 1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Food Business Loans & NBFCs'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Venture Capital / Angel Investors (Food Startups)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    ), 1, 2
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Venture Capital / Angel Investors (Food Startups)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Insurance (Product Liability, Stock, Supply Chain)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    ), 1, 3
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Insurance (Product Liability, Stock, Supply Chain)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'CA & Tax Advisory for Food Businesses', (
        SELECT id
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    ), 1, 4
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'CA & Tax Advisory for Food Businesses'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    categories (
        id,
        name,
        parent_id,
        is_active,
        display_order
    )
SELECT UUID(), 'Legal Services (Trademark, IP, FSSAI Compliances)', (
        SELECT id
        FROM categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
            AND parent_id IS NULL
    ), 1, 5
WHERE
    NOT EXISTS (
        SELECT 1
        FROM categories
        WHERE
            name = 'Legal Services (Trademark, IP, FSSAI Compliances)'
            AND parent_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                    AND parent_id IS NULL
            )
    );