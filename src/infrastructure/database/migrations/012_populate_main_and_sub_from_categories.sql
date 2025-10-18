-- Populate main_categories and sub_categories from existing categories

-- Insert mains (parent_id IS NULL)
INSERT INTO
    main_categories (
        id,
        name,
        description,
        image_url,
        display_order,
        is_active
    )
SELECT c.id, c.name, c.description, c.image_url, c.display_order, c.is_active
FROM
    categories c
    LEFT JOIN main_categories mc ON mc.id = c.id
WHERE
    c.parent_id IS NULL
    AND mc.id IS NULL;

-- Insert subs (only second-level: parent is a MAIN category)
INSERT INTO
    sub_categories (
        id,
        main_category_id,
        name,
        description,
        image_url,
        display_order,
        is_active
    )
SELECT c.id, p.id AS main_category_id, c.name, c.description, c.image_url, c.display_order, c.is_active
FROM
    categories c
    JOIN categories p ON p.id = c.parent_id
    JOIN main_categories mc ON mc.id = p.id
    LEFT JOIN sub_categories sc ON sc.id = c.id
WHERE
    p.parent_id IS NULL
    AND sc.id IS NULL;