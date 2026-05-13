-- =============================================================================
-- Nova Retail Group | Data Generation Script
-- =============================================================================
-- Description: Populate the database with 3 years of realistic sales data
-- Generates: ~3 years of dim_date, 5,000 customers, 50,000+ sales
-- Note: PostgreSQL syntax. Adapt for SQL Server or MySQL as needed.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Populate dim_date (2022-01-01 to 2024-12-31)
-- -----------------------------------------------------------------------------
INSERT INTO dim_date (date_key, full_date, day_of_week, day_number, month_number, month_name, quarter, year, is_weekend)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT                 AS date_key,
    d                                           AS full_date,
    TRIM(TO_CHAR(d, 'Day'))                     AS day_of_week,
    EXTRACT(DAY FROM d)::INT                    AS day_number,
    EXTRACT(MONTH FROM d)::INT                  AS month_number,
    TRIM(TO_CHAR(d, 'Month'))                   AS month_name,
    EXTRACT(QUARTER FROM d)::INT                AS quarter,
    EXTRACT(YEAR FROM d)::INT                   AS year,
    EXTRACT(DOW FROM d) IN (0, 6)               AS is_weekend
FROM generate_series('2022-01-01'::DATE, '2024-12-31'::DATE, '1 day'::INTERVAL) d
ON CONFLICT (date_key) DO NOTHING;


-- -----------------------------------------------------------------------------
-- 2. Generate 5,000 customers
-- -----------------------------------------------------------------------------
INSERT INTO dim_customer (customer_key, customer_code, first_name, last_name, email, age_group, gender, loyalty_tier, signup_date)
SELECT
    n + 100                                          AS customer_key,
    'CUST-' || LPAD((n + 100)::TEXT, 5, '0')         AS customer_code,
    (ARRAY['Thandi','Sipho','Lerato','Pieter','Aisha','Thabo','Nomvula','Johan',
           'Zanele','David','Mpho','Karabo','Naledi','Sarah','Michael','Brenda',
           'Tumi','Kagiso','Refilwe','Andrew'])[1 + (RANDOM()*19)::INT]  AS first_name,
    (ARRAY['Mokoena','Dlamini','Nkosi','van der Merwe','Patel','Mahlangu',
           'Khumalo','Botha','Mthembu','Smith','Naidoo','Jacobs','Pillay',
           'Coetzee','Maluleke','Sithole','Pretorius','Williams','Khumalo','Mabaso'])[1 + (RANDOM()*19)::INT] AS last_name,
    'customer' || (n + 100) || '@email.com'          AS email,
    (ARRAY['18-24','25-34','35-44','45-54','55+'])[1 + (RANDOM()*4)::INT] AS age_group,
    (ARRAY['M','F'])[1 + (RANDOM()*1)::INT]          AS gender,
    (ARRAY['Bronze','Bronze','Bronze','Silver','Silver','Gold','Platinum'])[1 + (RANDOM()*6)::INT] AS loyalty_tier,
    DATE '2018-01-01' + (RANDOM() * 2000)::INT       AS signup_date
FROM generate_series(1, 5000) n;


-- -----------------------------------------------------------------------------
-- 3. Generate ~50,000 sales transactions across 2022-2024
-- -----------------------------------------------------------------------------
INSERT INTO fact_sales (sale_id, date_key, product_key, store_key, customer_key,
                        quantity, unit_price, discount_pct, total_amount, payment_method)
SELECT
    n + 100                                          AS sale_id,
    -- Random date weighted toward recent months
    (SELECT date_key
       FROM dim_date
       ORDER BY RANDOM()
       LIMIT 1)                                      AS date_key,
    1 + (RANDOM() * 9)::INT                          AS product_key,
    1 + (RANDOM() * 9)::INT                          AS store_key,
    100 + (RANDOM() * 4999)::INT                     AS customer_key,
    1 + (RANDOM() * 4)::INT                          AS quantity,
    p.unit_price                                     AS unit_price,
    (ARRAY[0, 0, 0, 5, 10, 15, 20])[1 + (RANDOM()*6)::INT]::DECIMAL AS discount_pct,
    -- total_amount calculated below; placeholder using subquery
    p.unit_price *
        (1 + (RANDOM() * 4)::INT) *
        (1 - (ARRAY[0, 0, 0, 5, 10, 15, 20])[1 + (RANDOM()*6)::INT] / 100.0) AS total_amount,
    (ARRAY['Card','Card','Card','Cash','EFT'])[1 + (RANDOM()*4)::INT] AS payment_method
FROM generate_series(1, 50000) n
JOIN dim_product p ON p.product_key = 1 + (RANDOM() * 9)::INT;


-- -----------------------------------------------------------------------------
-- 4. Verify row counts
-- -----------------------------------------------------------------------------
SELECT 'dim_date'     AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_product',  COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store',    COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'fact_sales',   COUNT(*) FROM fact_sales;


-- -----------------------------------------------------------------------------
-- 5. Quick sanity check
-- -----------------------------------------------------------------------------
SELECT
    d.year,
    COUNT(*)                AS transactions,
    ROUND(SUM(f.total_amount)::NUMERIC, 0) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;
