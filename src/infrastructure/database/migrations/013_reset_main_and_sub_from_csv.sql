-- Reset main_categories and sub_categories from CSV (VIRAL KEYWORDS.xlsx - B2B (1).csv)
-- Strategy: truncate sub_categories then main_categories; insert mains in CSV order; insert subs mapped by main name

SET FOREIGN_KEY_CHECKS = 0;

-- Extra safety: delete existing rows to avoid duplicates if TRUNCATE is skipped by runner
SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM sub_categories;

DELETE FROM main_categories;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;

TRUNCATE TABLE sub_categories;

TRUNCATE TABLE main_categories;

SET FOREIGN_KEY_CHECKS = 1;

-- Insert main categories (display_order follows CSV order)
INSERT INTO
    main_categories (
        id,
        name,
        description,
        image_url,
        display_order,
        is_active
    )
VALUES (
        UUID(),
        'Fresh Produce',
        NULL,
        NULL,
        1,
        1
    ),
    (
        UUID(),
        'Grains, Pulses & Cereals',
        NULL,
        NULL,
        2,
        1
    ),
    (
        UUID(),
        'Dairy & Dairy Alternatives',
        NULL,
        NULL,
        3,
        1
    ),
    (
        UUID(),
        'Meat, Poultry & Seafood',
        NULL,
        NULL,
        4,
        1
    ),
    (
        UUID(),
        'Beverages',
        NULL,
        NULL,
        5,
        1
    ),
    (
        UUID(),
        'Oils, Fats & Spices',
        NULL,
        NULL,
        6,
        1
    ),
    (
        UUID(),
        'Bakery, Confectionery & Snacks',
        NULL,
        NULL,
        7,
        1
    ),
    (
        UUID(),
        'Packaged & Processed Foods',
        NULL,
        NULL,
        8,
        1
    ),
    (
        UUID(),
        'Health, Organic & Specialty Foods',
        NULL,
        NULL,
        9,
        1
    ),
    (
        UUID(),
        'Food Ingredients & Additives',
        NULL,
        NULL,
        10,
        1
    ),
    (
        UUID(),
        'HoReCa & Institutional Supplies',
        NULL,
        NULL,
        11,
        1
    ),
    (
        UUID(),
        'Packaging & Allied Products',
        NULL,
        NULL,
        12,
        1
    ),
    (
        UUID(),
        'Cold Chain & Logistics',
        NULL,
        NULL,
        13,
        1
    ),
    (
        UUID(),
        'Food Processing & Machinery',
        NULL,
        NULL,
        14,
        1
    ),
    (
        UUID(),
        'Agri & Farm Supplies',
        NULL,
        NULL,
        15,
        1
    ),
    (
        UUID(),
        'Indian Snacks & Sweets',
        NULL,
        NULL,
        16,
        1
    ),
    (
        UUID(),
        'Food Testing & Certification',
        NULL,
        NULL,
        17,
        1
    ),
    (
        UUID(),
        'Branding, Marketing & Design',
        NULL,
        NULL,
        18,
        1
    ),
    (
        UUID(),
        'Consultancy & Advisory Services',
        NULL,
        NULL,
        19,
        1
    ),
    (
        UUID(),
        'Infrastructure & Turnkey Solutions',
        NULL,
        NULL,
        20,
        1
    ),
    (
        UUID(),
        'Training, Skill Development & Manpower',
        NULL,
        NULL,
        21,
        1
    ),
    (
        UUID(),
        'Finance, Insurance & Legal Support',
        NULL,
        NULL,
        22,
        1
    );

-- Fresh Produce subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Fruits' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Domestic' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Imported' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Seasonal & Exotic' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Vegetables' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Root Vegetables' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Leafy Greens' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Exotic Veggies' AS name, 8 AS display_order
        UNION ALL
        SELECT 'Herbs & Spices (Fresh)' AS name, 9 AS display_order
        UNION ALL
        SELECT 'Organic Produce' AS name, 10 AS display_order
        UNION ALL
        SELECT 'Pre-cut & Packaged Produce' AS name, 11 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Fresh Produce';

-- Grains, Pulses & Cereals subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Rice' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Basmati' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Non-Basmati' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Parboiled' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Organic' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Wheat & Products' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Whole Wheat (Atta)' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Refined Flour (Maida, Sooji)' AS name, 8 AS display_order
        UNION ALL
        SELECT 'Bran & Byproducts' AS name, 9 AS display_order
        UNION ALL
        SELECT 'Pulses & Lentils' AS name, 10 AS display_order
        UNION ALL
        SELECT 'Millets & Ancient Grains' AS name, 11 AS display_order
        UNION ALL
        SELECT 'Corn & Maize Products' AS name, 12 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Grains, Pulses & Cereals';

-- Dairy & Dairy Alternatives subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Milk & Cream' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Butter, Ghee & Paneer' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Yogurt, Curd & Lassi' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Cheese (Processed, Artisan, Specialty)' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Dairy Ingredients (Milk Powder, Whey, Casein)' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Plant-based Dairy (Soy, Almond, Oat, Coconut)' AS name, 6 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Dairy & Dairy Alternatives';

-- Meat, Poultry & Seafood subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Fresh Meat' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Mutton, Pork, Beef' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Poultry' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Chicken, Duck, Turkey' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Eggs & Egg Products' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Seafood' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Fresh Fish' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Frozen Fish' AS name, 8 AS display_order
        UNION ALL
        SELECT 'Shellfish (Shrimp, Crab, Lobster)' AS name, 9 AS display_order
        UNION ALL
        SELECT 'Processed Meat & Seafood (Nuggets, Sausages, Kebabs)' AS name, 10 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Meat, Poultry & Seafood';

-- Beverages subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Water & Mineral Water' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Juices & Fruit Beverages' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Carbonated Drinks & Energy Drinks' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Tea' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Black Tea' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Green Tea' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Herbal & Specialty Tea' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Coffee' AS name, 8 AS display_order
        UNION ALL
        SELECT 'Roasted Beans' AS name, 9 AS display_order
        UNION ALL
        SELECT 'Ground Coffee' AS name, 10 AS display_order
        UNION ALL
        SELECT 'Instant Coffee' AS name, 11 AS display_order
        UNION ALL
        SELECT 'Alcoholic Beverages' AS name, 12 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Beverages';

-- Oils, Fats & Spices subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Edible Oils' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Sunflower, Groundnut, Mustard, Olive, Palm', 2
        UNION ALL
        SELECT 'Ghee, Vanaspati & Margarine', 3
        UNION ALL
        SELECT 'Whole Spices', 4
        UNION ALL
        SELECT 'Ground Spices', 5
        UNION ALL
        SELECT 'Blended Masalas & Seasonings', 6
        UNION ALL
        SELECT 'Pickles, Chutneys & Sauces', 7
    ) s ON 1 = 1
WHERE
    mc.name = 'Oils, Fats & Spices';

-- Bakery, Confectionery & Snacks subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Bakery' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Bread, Buns, Rolls' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Cakes, Pastries, Muffins' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Biscuits & Cookies' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Chocolates & Candies' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Indian Snacks (Namkeen, Farsan, Bhujia)' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Chips, Extruded Snacks & Popcorn' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Breakfast Cereals & Granola' AS name, 8 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Bakery, Confectionery & Snacks';

-- Packaged & Processed Foods subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Ready-to-Eat Meals' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Ready-to-Cook Meals' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Instant Foods (Noodles, Pasta, Soups)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Frozen Foods' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Frozen Vegetables' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Frozen Snacks (Parathas, Samosas, Patties)' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Canned & Jarred Foods' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Nutritional & Functional Foods' AS name, 8 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Packaged & Processed Foods';

-- Health, Organic & Specialty Foods subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Organic Foods' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Gluten-Free Foods' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Vegan & Plant-based Foods' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Keto, Low-Carb, Sugar-Free Foods' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Superfoods (Chia, Flax, Spirulina, Moringa)' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Ayurvedic & Herbal Products' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Nutraceuticals & Health Supplements' AS name, 7 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Health, Organic & Specialty Foods';

-- Food Ingredients & Additives subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Flours & Starches' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Sweeteners (Sugar, Jaggery, Honey, Stevia)' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Food Colours, Flavors & Extracts' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Preservatives, Stabilizers & Emulsifiers' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Baking Ingredients (Yeast, Cocoa, Chocolate, Vanilla' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Food Ingredients & Additives';

-- HoReCa & Institutional Supplies subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Bulk Grains, Pulses & Oils' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Bulk Dairy & Meat Products' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Sauces, Dressings & Marinades (Bulk)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Ready Mixes for Hotels & Caterers' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Frozen Bulk Supplies for HoReCa' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'HoReCa & Institutional Supplies';

-- Packaging & Allied Products subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Packaging' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Boxes, Trays, Pouches, Cans, Bottles' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Eco-friendly Packaging (Biodegradable, Compostable)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Labels, Stickers & Barcodes' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Storage Containers & Utensils' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Industrial Packaging Solutions' AS name, 6 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Packaging & Allied Products';

-- Cold Chain & Logistics subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Cold Storage Services' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Refrigerated Transport' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Warehousing Solutions' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Supply Chain Management Tools' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Logistics solutions' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Cold Chain & Logistics';

-- Food Processing & Machinery subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Processing Equipment' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Dairy Processing Machinery' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Meat & Seafood Processing Machines' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Beverage Processing Units' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Bakery & Confectionery Equipment' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Commercial Kitchen Equipment' AS name, 6 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Food Processing & Machinery';

-- Agri & Farm Supplies subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Seeds, Fertilizers & Pesticides' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Agri-Tech & Smart Farming Tools' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Animal Feed & Nutrition' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Aquaculture & Fishery Supplies' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Hydroponics & Vertical Farming Inputs' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Agri & Farm Supplies';

-- Indian Snacks & Sweets subs (Abridged from CSV order; includes all listed items)
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Namkeen & Mixtures' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Bhujia' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Chivda / Poha Mix' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Sev (Plain, Masala, Garlic, Nylon)' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Regional Mixtures (South Indian, Bombay, North Indian)' AS name, 5 AS display_order
        UNION ALL
        SELECT 'Farsan & Regional Snacks' AS name, 6 AS display_order
        UNION ALL
        SELECT 'Kachori, Samosa, Mathri' AS name, 7 AS display_order
        UNION ALL
        SELECT 'Chakli / Murukku' AS name, 8 AS display_order
        UNION ALL
        SELECT 'Banana Chips, Tapioca Chips' AS name, 9 AS display_order
        UNION ALL
        SELECT 'Khakhra & Papad' AS name, 10 AS display_order
        UNION ALL
        SELECT 'Roasted & Baked Snacks' AS name, 11 AS display_order
        UNION ALL
        SELECT 'Roasted Chana / Peanuts' AS name, 12 AS display_order
        UNION ALL
        SELECT 'Makhana (Fox Nuts)' AS name, 13 AS display_order
        UNION ALL
        SELECT 'Baked Mathri / Khakhra' AS name, 14 AS display_order
        UNION ALL
        SELECT 'Extruded Snacks & Chips' AS name, 15 AS display_order
        UNION ALL
        SELECT 'Potato Chips' AS name, 16 AS display_order
        UNION ALL
        SELECT 'Kurkure-style Extruded Snacks' AS name, 17 AS display_order
        UNION ALL
        SELECT 'Popcorn' AS name, 18 AS display_order
        UNION ALL
        SELECT 'Traditional Sweets' AS name, 19 AS display_order
        UNION ALL
        SELECT 'Ladoo (Besan, Motichoor, Coconut, Boondi, Til)' AS name, 20 AS display_order
        UNION ALL
        SELECT 'Barfi (Kaju Katli, Coconut, Besan, Badam, Chocolate)' AS name, 21 AS display_order
        UNION ALL
        SELECT 'Halwa (Sooji, Moong Dal, Gajar, Karachi Halwa)' AS name, 22 AS display_order
        UNION ALL
        SELECT 'Milk-based Sweets' AS name, 23 AS display_order
        UNION ALL
        SELECT 'Rasgulla, Gulab Jamun, Cham Cham' AS name, 24 AS display_order
        UNION ALL
        SELECT 'Rasmalai, Malai Sandwich' AS name, 25 AS display_order
        UNION ALL
        SELECT 'Kalakand, Milk Cake, Peda' AS name, 26 AS display_order
        UNION ALL
        SELECT 'Regional Specialties' AS name, 27 AS display_order
        UNION ALL
        SELECT 'Mysore Pak, Dharwad Peda, Sandesh, Mishti Doi' AS name, 28 AS display_order
        UNION ALL
        SELECT 'Petha, Ghevar, Balushahi' AS name, 29 AS display_order
        UNION ALL
        SELECT 'Modak, Kozhukattai, Poli' AS name, 30 AS display_order
        UNION ALL
        SELECT 'Modern & Fusion Sweets' AS name, 31 AS display_order
        UNION ALL
        SELECT 'Dry Fruit Rolls' AS name, 32 AS display_order
        UNION ALL
        SELECT 'Chocolate-dipped Mithai' AS name, 33 AS display_order
        UNION ALL
        SELECT 'Sugar-free / Low-calorie Sweets' AS name, 34 AS display_order
        UNION ALL
        SELECT 'Diwali Specials (Soan Papdi, Kaju Katli, Mix Mithai Boxes)' AS name, 35 AS display_order
        UNION ALL
        SELECT 'Holi Specials (Gujiya, Malpua, Thandai Mix)' AS name, 36 AS display_order
        UNION ALL
        SELECT 'Raksha Bandhan (Gift Packs, Premium Dry Fruit Mithai)' AS name, 37 AS display_order
        UNION ALL
        SELECT 'Eid Specials (Sheer Khurma Mix, Sewai, Baklava)' AS name, 38 AS display_order
        UNION ALL
        SELECT 'Christmas Specials (Plum Cake, Dry Fruit Cake)' AS name, 39 AS display_order
        UNION ALL
        SELECT 'Vacuum-packed Mithai (long shelf life)' AS name, 40 AS display_order
        UNION ALL
        SELECT 'Frozen Snacks (Samosa, Kachori, Patties)' AS name, 41 AS display_order
        UNION ALL
        SELECT 'Sweet Gift Hampers (Corporate, Wedding, Festive)' AS name, 42 AS display_order
        UNION ALL
        SELECT 'Namkeen Gift Packs' AS name, 43 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Indian Snacks & Sweets';

-- Food Testing & Certification subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Testing Labs (FSSAI-approved)' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Quality Certification Agencies (ISO, HACCP, BRC, Halal, Organic)' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Food Safety & Hygiene Auditors' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Nutritional Analysis Labs' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Microbiology & Shelf-life Testing' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Food Testing & Certification';

-- Branding, Marketing & Design subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Branding & Creative Agencies' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Packaging Design Services' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Food Photography & Videography' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Digital Marketing Agencies (SEO, Social Media, Ads)' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Trade Show & Event Management for Food' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Branding, Marketing & Design';

-- Consultancy & Advisory Services subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Industry Consultants (Product Development, Scale-up)' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Legal & Regulatory Consultants (FSSAI, Labeling, Import-Export)' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Export-Import Consultants (APEDA, DGFT, Customs)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Supply Chain & Logistics Consultants' AS name, 4 AS display_order
        UNION ALL
        SELECT 'HoReCa Consulting (Menu Engineering, Kitchen Setup)' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Consultancy & Advisory Services';

-- Infrastructure & Turnkey Solutions subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Cold Storage & Warehouse Developers' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Food Park / Industrial Park Developers' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Turnkey Food Processing Plant Setup Companies' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Commercial Kitchen Setup & AMC Services' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Packaging & Machinery Integrators' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Infrastructure & Turnkey Solutions';

-- Training, Skill Development & Manpower subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Technology Training Institutes' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Culinary Schools & HoReCa Training' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Skill Development Agencies (NSDC, Sector Skill Councils)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'Blue-collar Manpower Agencies (Chefs, Workers, Packers)' AS name, 4 AS display_order
        UNION ALL
        SELECT 'HR & Staffing Agencies (for Food Industry' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Training, Skill Development & Manpower';

-- Finance, Insurance & Legal Support subs
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
SELECT UUID(), mc.id, s.name, NULL, NULL, s.display_order, 1
FROM main_categories mc
    JOIN (
        SELECT 'Food Business Loans & NBFCs' AS name, 1 AS display_order
        UNION ALL
        SELECT 'Venture Capital / Angel Investors (Food Startups)' AS name, 2 AS display_order
        UNION ALL
        SELECT 'Insurance (Product Liability, Stock, Supply Chain)' AS name, 3 AS display_order
        UNION ALL
        SELECT 'CA & Tax Advisory for Food Businesses' AS name, 4 AS display_order
        UNION ALL
        SELECT 'Legal Services (Trademark, IP, FSSAI Compliances)' AS name, 5 AS display_order
    ) s ON 1 = 1
WHERE
    mc.name = 'Finance, Insurance & Legal Support';