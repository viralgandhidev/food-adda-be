-- Fix FK errors by mapping products.category_id to legacy categories via names
-- After we reset main/sub with new UUIDs, their ids don't exist in categories
-- This script aligns products.category_id to the matching categories.id by name

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

-- 1) Prefer sub category name match
UPDATE products p
JOIN sub_categories sc ON sc.id = p.sub_category_id
JOIN categories c ON c.name = sc.name
SET
    p.category_id = c.id
WHERE
    p.sub_category_id IS NOT NULL
    AND p.category_id <> c.id;

-- 2) Fallback to main category name match where sub is null
UPDATE products p
JOIN main_categories mc ON mc.id = p.main_category_id
JOIN categories c ON c.name = mc.name
SET
    p.category_id = c.id
WHERE
    p.sub_category_id IS NULL
    AND p.main_category_id IS NOT NULL
    AND p.category_id <> c.id;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;