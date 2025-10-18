-- Reset keywords and seed from CSV mapping (columns mapped to main categories by order)

SET FOREIGN_KEY_CHECKS = 0;

SET @prev_sql_safe_updates := @@SQL_SAFE_UPDATES;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM keywords;

TRUNCATE TABLE keywords;

SET SQL_SAFE_UPDATES = @prev_sql_safe_updates;

SET FOREIGN_KEY_CHECKS = 1;

-- Helper: function-like SELECT to resolve main id by name
-- Fresh Produce
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Fresh Produce'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Apple' AS name
        UNION ALL
        SELECT 'Apricot'
        UNION ALL
        SELECT 'Avocado'
        UNION ALL
        SELECT 'Butter Fruit'
        UNION ALL
        SELECT 'Banana'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Fresh Produce'
                LIMIT 1
            )
    );

-- Grains, Pulses & Cereals
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Grains, Pulses & Cereals'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Buckwheat Flour' AS name
        UNION ALL
        SELECT 'Amaranth Flour'
        UNION ALL
        SELECT 'Chestnut Flour'
        UNION ALL
        SELECT 'Tapioca Flour'
        UNION ALL
        SELECT 'Coconut Flour'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Grains, Pulses & Cereals'
                LIMIT 1
            )
    );

-- Dairy & Dairy Alternatives
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Dairy & Dairy Alternatives'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Milk & Cream' AS name
        UNION ALL
        SELECT 'Butter, Ghee & Paneer'
        UNION ALL
        SELECT 'Yogurt, Curd & Lassi'
        UNION ALL
        SELECT 'Cheese (Processed, Artisan, Specialty)'
        UNION ALL
        SELECT 'Dairy Ingredients (Milk Powder, Whey, Casein)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Dairy & Dairy Alternatives'
                LIMIT 1
            )
    );

-- Meat, Poultry & Seafood
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Meat, Poultry & Seafood'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Fresh Meat' AS name
        UNION ALL
        SELECT 'Mutton, Pork, Beef'
        UNION ALL
        SELECT 'Poultry'
        UNION ALL
        SELECT 'Chicken, Duck, Turkey'
        UNION ALL
        SELECT 'Eggs & Egg Products'
        UNION ALL
        SELECT 'Seafood'
        UNION ALL
        SELECT 'Fresh Fish'
        UNION ALL
        SELECT 'Frozen Fish'
        UNION ALL
        SELECT 'Shellfish (Shrimp, Crab, Lobster)'
        UNION ALL
        SELECT 'Processed Meat & Seafood (Nuggets, Sausages, Kebabs)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Meat, Poultry & Seafood'
                LIMIT 1
            )
    );

-- Beverages
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Beverages'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Water & Mineral Water' AS name
        UNION ALL
        SELECT 'Juices & Fruit Beverages'
        UNION ALL
        SELECT 'Carbonated Drinks & Energy Drinks'
        UNION ALL
        SELECT 'Tea'
        UNION ALL
        SELECT 'Black Tea'
        UNION ALL
        SELECT 'Green Tea'
        UNION ALL
        SELECT 'Herbal & Specialty Tea'
        UNION ALL
        SELECT 'Coffee'
        UNION ALL
        SELECT 'Roasted Beans'
        UNION ALL
        SELECT 'Ground Coffee'
        UNION ALL
        SELECT 'Instant Coffee'
        UNION ALL
        SELECT 'Alcoholic Beverages'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Beverages'
                LIMIT 1
            )
    );

-- Oils, Fats & Spices
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Oils, Fats & Spices'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Triple Refined Free Flow Salt' AS name
        UNION ALL
        SELECT 'Edible Oils'
        UNION ALL
        SELECT 'Sunflower, Groundnut, Mustard, Olive, Palm'
        UNION ALL
        SELECT 'Ghee, Vanaspati & Margarine'
        UNION ALL
        SELECT 'Whole Spices'
        UNION ALL
        SELECT 'Ground Spices'
        UNION ALL
        SELECT 'Blended Masalas & Seasonings'
        UNION ALL
        SELECT 'Pickles, Chutneys & Sauces'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Oils, Fats & Spices'
                LIMIT 1
            )
    );

-- Bakery, Confectionery & Snacks
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Bakery, Confectionery & Snacks'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Bakery' AS name
        UNION ALL
        SELECT 'Bread, Buns, Rolls'
        UNION ALL
        SELECT 'Cakes, Pastries, Muffins'
        UNION ALL
        SELECT 'Biscuits & Cookies'
        UNION ALL
        SELECT 'Chocolates & Candies'
        UNION ALL
        SELECT 'Indian Snacks (Namkeen, Farsan, Bhujia)'
        UNION ALL
        SELECT 'Chips, Extruded Snacks & Popcorn'
        UNION ALL
        SELECT 'Breakfast Cereals & Granola'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Bakery, Confectionery & Snacks'
                LIMIT 1
            )
    );

-- Packaged & Processed Foods
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Packaged & Processed Foods'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Ready-to-Eat Meals' AS name
        UNION ALL
        SELECT 'Ready-to-Cook Meals'
        UNION ALL
        SELECT 'Instant Foods (Noodles, Pasta, Soups)'
        UNION ALL
        SELECT 'Frozen Foods'
        UNION ALL
        SELECT 'Frozen Vegetables'
        UNION ALL
        SELECT 'Frozen Snacks (Parathas, Samosas, Patties)'
        UNION ALL
        SELECT 'Canned & Jarred Foods'
        UNION ALL
        SELECT 'Nutritional & Functional Foods'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Packaged & Processed Foods'
                LIMIT 1
            )
    );

-- Health, Organic & Specialty Foods
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Health, Organic & Specialty Foods'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Organic Foods' AS name
        UNION ALL
        SELECT 'Gluten-Free Foods'
        UNION ALL
        SELECT 'Vegan & Plant-based Foods'
        UNION ALL
        SELECT 'Keto, Low-Carb, Sugar-Free Foods'
        UNION ALL
        SELECT 'Superfoods (Chia, Flax, Spirulina, Moringa)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Health, Organic & Specialty Foods'
                LIMIT 1
            )
    );

-- Food Ingredients & Additives
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Food Ingredients & Additives'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Flours & Starches' AS name
        UNION ALL
        SELECT 'Sweeteners (Sugar, Jaggery, Honey, Stevia)'
        UNION ALL
        SELECT 'Food Colours, Flavors & Extracts'
        UNION ALL
        SELECT 'Preservatives, Stabilizers & Emulsifiers'
        UNION ALL
        SELECT 'Baking Ingredients (Yeast, Cocoa, Chocolate, Vanilla'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Food Ingredients & Additives'
                LIMIT 1
            )
    );

-- HoReCa & Institutional Supplies
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'HoReCa & Institutional Supplies'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Bulk Grains, Pulses & Oils' AS name
        UNION ALL
        SELECT 'Bulk Dairy & Meat Products'
        UNION ALL
        SELECT 'Sauces, Dressings & Marinades (Bulk)'
        UNION ALL
        SELECT 'Ready Mixes for Hotels & Caterers'
        UNION ALL
        SELECT 'Frozen Bulk Supplies for HoReCa'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'HoReCa & Institutional Supplies'
                LIMIT 1
            )
    );

-- Packaging & Allied Products
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Packaging & Allied Products'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Packaging' AS name
        UNION ALL
        SELECT 'Boxes, Trays, Pouches, Cans, Bottles'
        UNION ALL
        SELECT 'Eco-friendly Packaging (Biodegradable, Compostable)'
        UNION ALL
        SELECT 'Labels, Stickers & Barcodes'
        UNION ALL
        SELECT 'Storage Containers & Utensils'
        UNION ALL
        SELECT 'Industrial Packaging Solutions'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Packaging & Allied Products'
                LIMIT 1
            )
    );

-- Cold Chain & Logistics
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Cold Chain & Logistics'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Cold Storage Services' AS name
        UNION ALL
        SELECT 'Refrigerated Transport'
        UNION ALL
        SELECT 'Warehousing Solutions'
        UNION ALL
        SELECT 'Supply Chain Management Tools'
        UNION ALL
        SELECT 'Logistics solutions'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Cold Chain & Logistics'
                LIMIT 1
            )
    );

-- Food Processing & Machinery
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Food Processing & Machinery'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Processing Equipment' AS name
        UNION ALL
        SELECT 'Dairy Processing Machinery'
        UNION ALL
        SELECT 'Meat & Seafood Processing Machines'
        UNION ALL
        SELECT 'Beverage Processing Units'
        UNION ALL
        SELECT 'Bakery & Confectionery Equipment'
        UNION ALL
        SELECT 'Commercial Kitchen Equipment'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Food Processing & Machinery'
                LIMIT 1
            )
    );

-- Agri & Farm Supplies
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Agri & Farm Supplies'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Seeds, Fertilizers & Pesticides' AS name
        UNION ALL
        SELECT 'Agri-Tech & Smart Farming Tools'
        UNION ALL
        SELECT 'Animal Feed & Nutrition'
        UNION ALL
        SELECT 'Aquaculture & Fishery Supplies'
        UNION ALL
        SELECT 'Hydroponics & Vertical Farming Inputs'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Agri & Farm Supplies'
                LIMIT 1
            )
    );

-- Indian Snacks & Sweets
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Indian Snacks & Sweets'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'A. Indian Snacks (Savory)' AS name
        UNION ALL
        SELECT 'Namkeen & Mixtures'
        UNION ALL
        SELECT 'Bhujia'
        UNION ALL
        SELECT 'Chivda / Poha Mix'
        UNION ALL
        SELECT 'Sev (Plain, Masala, Garlic, Nylon)'
        UNION ALL
        SELECT 'B. Indian Sweets (Mithai & Desserts)'
        UNION ALL
        SELECT 'Traditional Sweets'
        UNION ALL
        SELECT 'Ladoo (Besan, Motichoor, Coconut, Boondi, Til)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Indian Snacks & Sweets'
                LIMIT 1
            )
    );

-- Food Testing & Certification
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Food Testing & Certification'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Testing Labs (FSSAI-approved)' AS name
        UNION ALL
        SELECT 'Quality Certification Agencies (ISO, HACCP, BRC, Halal, Organic)'
        UNION ALL
        SELECT 'Food Safety & Hygiene Auditors'
        UNION ALL
        SELECT 'Nutritional Analysis Labs'
        UNION ALL
        SELECT 'Microbiology & Shelf-life Testing'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Food Testing & Certification'
                LIMIT 1
            )
    );

-- Branding, Marketing & Design
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Branding, Marketing & Design'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Branding & Creative Agencies' AS name
        UNION ALL
        SELECT 'Packaging Design Services'
        UNION ALL
        SELECT 'Food Photography & Videography'
        UNION ALL
        SELECT 'Digital Marketing Agencies (SEO, Social Media, Ads)'
        UNION ALL
        SELECT 'Trade Show & Event Management for Food'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Branding, Marketing & Design'
                LIMIT 1
            )
    );

-- Consultancy & Advisory Services
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Consultancy & Advisory Services'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Industry Consultants (Product Development, Scale-up)' AS name
        UNION ALL
        SELECT 'Legal & Regulatory Consultants (FSSAI, Labeling, Import-Export)'
        UNION ALL
        SELECT 'Export-Import Consultants (APEDA, DGFT, Customs)'
        UNION ALL
        SELECT 'Supply Chain & Logistics Consultants'
        UNION ALL
        SELECT 'HoReCa Consulting (Menu Engineering, Kitchen Setup)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Consultancy & Advisory Services'
                LIMIT 1
            )
    );

-- Infrastructure & Turnkey Solutions
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Infrastructure & Turnkey Solutions'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Cold Storage & Warehouse Developers' AS name
        UNION ALL
        SELECT 'Food Park / Industrial Park Developers'
        UNION ALL
        SELECT 'Turnkey Food Processing Plant Setup Companies'
        UNION ALL
        SELECT 'Commercial Kitchen Setup & AMC Services'
        UNION ALL
        SELECT 'Packaging & Machinery Integrators'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Infrastructure & Turnkey Solutions'
                LIMIT 1
            )
    );

-- Training, Skill Development & Manpower
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Training, Skill Development & Manpower'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Technology Training Institutes' AS name
        UNION ALL
        SELECT 'Culinary Schools & HoReCa Training'
        UNION ALL
        SELECT 'Skill Development Agencies (NSDC, Sector Skill Councils)'
        UNION ALL
        SELECT 'Blue-collar Manpower Agencies (Chefs, Workers, Packers)'
        UNION ALL
        SELECT 'HR & Staffing Agencies (for Food Industry'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Training, Skill Development & Manpower'
                LIMIT 1
            )
    );

-- Finance, Insurance & Legal Support
INSERT INTO
    keywords (
        id,
        name,
        main_category_id,
        sub_category_id,
        is_active
    )
SELECT UUID(), k.name, (
        SELECT id
        FROM main_categories
        WHERE
            name = 'Finance, Insurance & Legal Support'
        LIMIT 1
    ), NULL, 1
FROM (
        SELECT 'Food Business Loans & NBFCs' AS name
        UNION ALL
        SELECT 'Venture Capital / Angel Investors (Food Startups)'
        UNION ALL
        SELECT 'Insurance (Product Liability, Stock, Supply Chain)'
        UNION ALL
        SELECT 'CA & Tax Advisory for Food Businesses'
        UNION ALL
        SELECT 'Legal Services (Trademark, IP, FSSAI Compliances)'
    ) k
WHERE
    NOT EXISTS (
        SELECT 1
        FROM keywords kw
        WHERE
            kw.name = k.name
            AND kw.main_category_id = (
                SELECT id
                FROM main_categories
                WHERE
                    name = 'Finance, Insurance & Legal Support'
                LIMIT 1
            )
    );