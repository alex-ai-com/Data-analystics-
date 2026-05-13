-- =============================================================================
-- Nova Retail Group | Sample Data
-- =============================================================================
-- Description: Seed data for testing and demo purposes
-- Note: This is a small sample. Full dataset is generated in 03_generate_data.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- DIM_DATE (sample — full population script is in 03_generate_data.sql)
-- -----------------------------------------------------------------------------
INSERT INTO dim_date (date_key, full_date, day_of_week, day_number, month_number, month_name, quarter, year, is_weekend) VALUES
(20240101, '2024-01-01', 'Monday',    1,  1, 'January',  1, 2024, FALSE),
(20240115, '2024-01-15', 'Monday',    15, 1, 'January',  1, 2024, FALSE),
(20240601, '2024-06-01', 'Saturday',  1,  6, 'June',     2, 2024, TRUE),
(20241225, '2024-12-25', 'Wednesday', 25, 12, 'December', 4, 2024, FALSE);

-- -----------------------------------------------------------------------------
-- DIM_PRODUCT
-- -----------------------------------------------------------------------------
INSERT INTO dim_product (product_key, product_code, product_name, category, subcategory, brand, unit_cost, unit_price) VALUES
(1, 'ELEC-001', 'Samsung 55" QLED TV',       'Electronics', 'Television',   'Samsung',  6800.00, 12999.00),
(2, 'ELEC-002', 'Apple iPhone 15 Pro',        'Electronics', 'Mobile',       'Apple',   18500.00, 27999.00),
(3, 'ELEC-003', 'Sony WH-1000XM5 Headphones', 'Electronics', 'Audio',        'Sony',     3200.00, 6499.00),
(4, 'APP-001',  'Nike Air Max 270',           'Apparel',     'Footwear',     'Nike',      650.00, 1899.00),
(5, 'APP-002',  'Adidas Ultraboost 22',       'Apparel',     'Footwear',     'Adidas',    780.00, 2299.00),
(6, 'HOME-001', 'LG Front Loader Washer',     'Home',        'Appliances',   'LG',       4200.00, 8999.00),
(7, 'HOME-002', 'Dyson V15 Vacuum',           'Home',        'Appliances',   'Dyson',    5800.00, 11499.00),
(8, 'BEA-001',  'L''Oreal Revitalift Serum',  'Beauty',      'Skincare',     'L''Oreal',  180.00, 449.00),
(9, 'BEA-002',  'MAC Ruby Woo Lipstick',      'Beauty',      'Makeup',       'MAC',        95.00, 295.00),
(10,'ELEC-004', 'PlayStation 5 Console',      'Electronics', 'Gaming',       'Sony',     7200.00, 11999.00);

-- -----------------------------------------------------------------------------
-- DIM_STORE
-- -----------------------------------------------------------------------------
INSERT INTO dim_store (store_key, store_code, store_name, province, city, store_type, open_date, floor_size_m2) VALUES
(1,  'JHB-001', 'Sandton City',         'Gauteng',       'Johannesburg', 'Flagship', '2018-03-15', 2400),
(2,  'JHB-002', 'Mall of Africa',       'Gauteng',       'Midrand',      'Standard', '2019-08-01', 1800),
(3,  'PTA-001', 'Menlyn Park',          'Gauteng',       'Pretoria',     'Standard', '2020-02-10', 1600),
(4,  'CPT-001', 'V&A Waterfront',       'Western Cape',  'Cape Town',    'Flagship', '2017-11-20', 2200),
(5,  'CPT-002', 'Canal Walk',           'Western Cape',  'Cape Town',    'Standard', '2021-05-05', 1500),
(6,  'DBN-001', 'Gateway Theatre',      'KwaZulu-Natal', 'Umhlanga',     'Standard', '2019-01-12', 1700),
(7,  'DBN-002', 'Pavilion',             'KwaZulu-Natal', 'Westville',    'Express',  '2022-06-18', 800),
(8,  'PE-001',  'Baywest Mall',         'Eastern Cape',  'Gqeberha',     'Standard', '2020-09-22', 1400),
(9,  'BFN-001', 'Mimosa Mall',          'Free State',    'Bloemfontein', 'Express',  '2021-11-30', 750),
(10, 'JHB-003', 'Rosebank',             'Gauteng',       'Johannesburg', 'Express',  '2023-04-14', 700);

-- -----------------------------------------------------------------------------
-- DIM_CUSTOMER (sample of 10 — full set in 03_generate_data.sql)
-- -----------------------------------------------------------------------------
INSERT INTO dim_customer (customer_key, customer_code, first_name, last_name, email, age_group, gender, loyalty_tier, signup_date) VALUES
(1,  'CUST-00001', 'Thandi',     'Mokoena',   'thandi.m@email.com',     '25-34', 'F', 'Gold',     '2022-03-15'),
(2,  'CUST-00002', 'Sipho',      'Dlamini',   'sipho.d@email.com',      '35-44', 'M', 'Silver',   '2021-07-22'),
(3,  'CUST-00003', 'Lerato',     'Nkosi',     'lerato.n@email.com',     '18-24', 'F', 'Bronze',   '2023-11-01'),
(4,  'CUST-00004', 'Pieter',     'van der Merwe', 'pieter.v@email.com', '45-54', 'M', 'Platinum', '2020-01-10'),
(5,  'CUST-00005', 'Aisha',      'Patel',     'aisha.p@email.com',      '25-34', 'F', 'Silver',   '2022-09-18'),
(6,  'CUST-00006', 'Thabo',      'Mahlangu',  'thabo.m@email.com',      '35-44', 'M', 'Gold',     '2021-04-30'),
(7,  'CUST-00007', 'Nomvula',    'Khumalo',   'nomvula.k@email.com',    '55+',   'F', 'Silver',   '2019-12-05'),
(8,  'CUST-00008', 'Johan',      'Botha',     'johan.b@email.com',      '45-54', 'M', 'Bronze',   '2023-02-14'),
(9,  'CUST-00009', 'Zanele',     'Mthembu',   'zanele.m@email.com',     '25-34', 'F', 'Gold',     '2022-06-08'),
(10, 'CUST-00010', 'David',      'Smith',     'david.s@email.com',      '35-44', 'M', 'Platinum', '2018-08-20');

-- -----------------------------------------------------------------------------
-- FACT_SALES (sample transactions)
-- -----------------------------------------------------------------------------
INSERT INTO fact_sales (sale_id, date_key, product_key, store_key, customer_key, quantity, unit_price, discount_pct, total_amount, payment_method) VALUES
(1, 20240101, 1,  1, 1,  1, 12999.00, 0,    12999.00, 'Card'),
(2, 20240101, 4,  1, 2,  2,  1899.00, 10,    3418.20, 'Card'),
(3, 20240115, 8,  4, 3,  3,   449.00, 0,     1347.00, 'EFT'),
(4, 20240115, 2,  2, 4,  1, 27999.00, 5,    26599.05, 'Card'),
(5, 20240601, 5,  4, 5,  1,  2299.00, 15,    1954.15, 'Cash'),
(6, 20240601, 6,  6, 6,  1,  8999.00, 0,     8999.00, 'Card'),
(7, 20241225, 10, 1, 7,  1, 11999.00, 0,    11999.00, 'Card'),
(8, 20241225, 9,  4, 8,  4,   295.00, 0,     1180.00, 'Card'),
(9, 20241225, 3,  3, 9,  1,  6499.00, 20,    5199.20, 'EFT'),
(10,20241225, 7,  5, 10, 1, 11499.00, 0,    11499.00, 'Card');

-- =============================================================================
-- VERIFICATION
-- =============================================================================
SELECT 'dim_date'     AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_product'  AS table_name, COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store'    AS table_name, COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_customer' AS table_name, COUNT(*) FROM dim_customer
UNION ALL
SELECT 'fact_sales'   AS table_name, COUNT(*) FROM fact_sales;
