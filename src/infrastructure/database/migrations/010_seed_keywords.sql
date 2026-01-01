-- Seed keywords by mapping each term to its main category (and sub when applicable)
-- Idempotent inserts using WHERE NOT EXISTS
-- Works with both categories table (initial state) and main_categories table (after migration 015)

-- Determine which table to use: if main_categories exists, use it; otherwise use categories
SET @use_main_categories = 0;
SELECT COUNT(*) INTO @use_main_categories
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'main_categories';

-- Use main_categories if table exists, otherwise use categories
SET @cat_table = IF(@use_main_categories > 0, 'main_categories', 'categories');
SET @cat_where = IF(@use_main_categories > 0, '', 'AND parent_id IS NULL');

-- Fresh Produce
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Apple'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Fresh Produce''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Apple''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Fresh Produce''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Apricot'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Fresh Produce''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Apricot''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Fresh Produce''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Grains, Pulses & Cereals
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Buckwheat Flour'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Grains, Pulses & Cereals''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Buckwheat Flour''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Grains, Pulses & Cereals''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Amaranth Flour'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Grains, Pulses & Cereals''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Amaranth Flour''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Grains, Pulses & Cereals''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Dairy & Dairy Alternatives
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Milk & Cream'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Dairy & Dairy Alternatives''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Milk & Cream''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Dairy & Dairy Alternatives''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Butter, Ghee & Paneer'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Dairy & Dairy Alternatives''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Butter, Ghee & Paneer''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Dairy & Dairy Alternatives''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Meat, Poultry & Seafood
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Fresh Meat'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Meat, Poultry & Seafood''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Fresh Meat''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Meat, Poultry & Seafood''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Mutton, Pork, Beef'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Meat, Poultry & Seafood''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Mutton, Pork, Beef''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Meat, Poultry & Seafood''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Beverages
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Water & Mineral Water'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Beverages''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Water & Mineral Water''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Beverages''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Juices & Fruit Beverages'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Beverages''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Juices & Fruit Beverages''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Beverages''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Oils, Fats & Spices
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Triple Refined Free Flow Salt'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Oils, Fats & Spices''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Triple Refined Free Flow Salt''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Oils, Fats & Spices''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Bakery, Confectionery & Snacks
SET @sql = CONCAT('
INSERT INTO keywords (id, name, main_category_id)
SELECT UUID(), ''Bakery'', (
    SELECT id FROM ', @cat_table, ' WHERE name = ''Bakery, Confectionery & Snacks''', @cat_where, ' LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = ''Bakery''
    AND main_category_id = (SELECT id FROM ', @cat_table, ' WHERE name = ''Bakery, Confectionery & Snacks''', @cat_where, ' LIMIT 1)
)');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- REPEAT: Continue inserting all provided keyword cells, mapped to the appropriate main category name (and sub_category_id if the keyword is specifically a subcategory label)
