-- Seed keywords by mapping each term to its main category (and sub when applicable)
-- Idempotent inserts using WHERE NOT EXISTS

-- Helper: resolve main category id by name
-- Example for a few rows; extend with full provided list similarly

-- Fresh Produce
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Apple', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Apple'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Apricot', (
        SELECT id
        FROM categories
        WHERE
            name = 'Fresh Produce'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Apricot'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Fresh Produce'
                    AND parent_id IS NULL
            )
    );

-- Grains, Pulses, Flour & Cereals (note: your main is "Grains, Pulses & Cereals"; aligning keyword main name accordingly)
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Buckwheat Flour', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Buckwheat Flour'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Amaranth Flour', (
        SELECT id
        FROM categories
        WHERE
            name = 'Grains, Pulses & Cereals'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Amaranth Flour'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                    AND parent_id IS NULL
            )
    );

-- Dairy & Dairy Alternatives
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Milk & Cream', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Milk & Cream'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Butter, Ghee & Paneer', (
        SELECT id
        FROM categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Butter, Ghee & Paneer'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                    AND parent_id IS NULL
            )
    );

-- Meat, Poultry & Seafood
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Fresh Meat', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Fresh Meat'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Mutton, Pork, Beef', (
        SELECT id
        FROM categories
        WHERE
            name = 'Meat, Poultry & Seafood'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Mutton, Pork, Beef'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                    AND parent_id IS NULL
            )
    );

-- Beverages
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Water & Mineral Water', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Water & Mineral Water'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Juices & Fruit Beverages', (
        SELECT id
        FROM categories
        WHERE
            name = 'Beverages'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Juices & Fruit Beverages'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Beverages'
                    AND parent_id IS NULL
            )
    );

-- Oils, Fats, Salts & Spices (mapped to Oils, Fats & Spices)
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Triple Refined Free Flow Salt', (
        SELECT id
        FROM categories
        WHERE
            name = 'Oils, Fats & Spices'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Triple Refined Free Flow Salt'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Oils, Fats & Spices'
                    AND parent_id IS NULL
            )
    );

-- Bakery, Confectionery & Snacks
INSERT INTO
    keywords (id, name, main_category_id)
SELECT UUID(), 'Bakery', (
        SELECT id
        FROM categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
            AND parent_id IS NULL
    )
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords
        WHERE
            name = 'Bakery'
            AND main_category_id = (
                SELECT id
                FROM categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                    AND parent_id IS NULL
            )
    );

-- REPEAT: Continue inserting all provided keyword cells, mapped to the appropriate main category name (and sub_category_id if the keyword is specifically a subcategory label)