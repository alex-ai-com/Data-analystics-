-- =============================================================================
-- Nova Retail Group | Database Schema
-- =============================================================================
-- Description: Star schema for sales analytics (PostgreSQL syntax)
-- Author: [Your Name]
-- Last updated: 2025-01
-- =============================================================================

-- Drop tables if they exist (safe re-run)
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Date dimension
CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,            -- YYYYMMDD format
    full_date       DATE NOT NULL,
    day_of_week     VARCHAR(10) NOT NULL,
    day_number      INT NOT NULL,
    month_number    INT NOT NULL,
    month_name      VARCHAR(10) NOT NULL,
    quarter         INT NOT NULL,
    year            INT NOT NULL,
    is_weekend      BOOLEAN NOT NULL,
    is_holiday      BOOLEAN DEFAULT FALSE
);

-- Product dimension
CREATE TABLE dim_product (
    product_key     INT PRIMARY KEY,
    product_code    VARCHAR(20) UNIQUE NOT NULL,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    subcategory     VARCHAR(50),
    brand           VARCHAR(50),
    unit_cost       DECIMAL(10, 2) NOT NULL CHECK (unit_cost >= 0),
    unit_price      DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    is_active       BOOLEAN DEFAULT TRUE
);

-- Store dimension
CREATE TABLE dim_store (
    store_key       INT PRIMARY KEY,
    store_code      VARCHAR(10) UNIQUE NOT NULL,
    store_name      VARCHAR(100) NOT NULL,
    province        VARCHAR(50) NOT NULL,
    city            VARCHAR(50) NOT NULL,
    store_type      VARCHAR(30) NOT NULL,        -- Flagship, Standard, Express
    open_date       DATE NOT NULL,
    floor_size_m2   INT
);

-- Customer dimension
CREATE TABLE dim_customer (
    customer_key    INT PRIMARY KEY,
    customer_code   VARCHAR(20) UNIQUE NOT NULL,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100),
    age_group       VARCHAR(20),                 -- 18-24, 25-34, 35-44, 45-54, 55+
    gender          VARCHAR(10),
    loyalty_tier    VARCHAR(20) DEFAULT 'Bronze',-- Bronze, Silver, Gold, Platinum
    signup_date     DATE NOT NULL
);

-- =============================================================================
-- FACT TABLE
-- =============================================================================

CREATE TABLE fact_sales (
    sale_id         BIGINT PRIMARY KEY,
    date_key        INT NOT NULL,
    product_key     INT NOT NULL,
    store_key       INT NOT NULL,
    customer_key    INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10, 2) NOT NULL,
    discount_pct    DECIMAL(5, 2) DEFAULT 0,
    total_amount    DECIMAL(12, 2) NOT NULL,
    payment_method  VARCHAR(20),
    -- Foreign keys
    CONSTRAINT fk_date     FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
    CONSTRAINT fk_product  FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
    CONSTRAINT fk_store    FOREIGN KEY (store_key)    REFERENCES dim_store(store_key),
    CONSTRAINT fk_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);

-- =============================================================================
-- INDEXES (for analytical query performance)
-- =============================================================================

CREATE INDEX idx_fact_sales_date     ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_product  ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_store    ON fact_sales(store_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);

CREATE INDEX idx_dim_date_year_month ON dim_date(year, month_number);
CREATE INDEX idx_dim_product_cat     ON dim_product(category, subcategory);
CREATE INDEX idx_dim_store_province  ON dim_store(province);

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE  fact_sales       IS 'Transactional sales facts at line-item grain';
COMMENT ON TABLE  dim_date         IS 'Date dimension covering 2022-2024';
COMMENT ON TABLE  dim_product      IS 'Product master with category hierarchy';
COMMENT ON TABLE  dim_store        IS 'Store master with location attributes';
COMMENT ON TABLE  dim_customer     IS 'Customer master with loyalty and demographics';
