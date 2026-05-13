# Data Dictionary

Reference for every table and column in the Nova Retail Group analytical model.

## fact_sales

The transactional grain table — one row per product line item per sale.

| Column          | Type           | Description                                        |
| --------------- | -------------- | -------------------------------------------------- |
| sale_id         | BIGINT (PK)    | Unique transaction line identifier                 |
| date_key        | INT (FK)       | Foreign key to `dim_date.date_key` (YYYYMMDD)      |
| product_key     | INT (FK)       | Foreign key to `dim_product.product_key`           |
| store_key       | INT (FK)       | Foreign key to `dim_store.store_key`               |
| customer_key    | INT (FK)       | Foreign key to `dim_customer.customer_key`         |
| quantity        | INT            | Number of units sold                               |
| unit_price      | DECIMAL(10,2)  | Selling price per unit at time of sale (ZAR)       |
| discount_pct    | DECIMAL(5,2)   | Discount percentage applied (0-100)                |
| total_amount    | DECIMAL(12,2)  | Final line total: quantity × unit_price × (1 - discount_pct/100) |
| payment_method  | VARCHAR(20)    | Card, Cash, or EFT                                 |

## dim_date

Calendar dimension covering 2022-01-01 to 2024-12-31.

| Column        | Type        | Description                                  |
| ------------- | ----------- | -------------------------------------------- |
| date_key      | INT (PK)    | Date in YYYYMMDD format (e.g. 20240315)      |
| full_date     | DATE        | Full date value                              |
| day_of_week   | VARCHAR(10) | Monday, Tuesday, etc.                        |
| day_number    | INT         | Day of month (1-31)                          |
| month_number  | INT         | Month number (1-12)                          |
| month_name    | VARCHAR(10) | January, February, etc.                      |
| quarter       | INT         | Calendar quarter (1-4)                       |
| year          | INT         | Calendar year                                |
| is_weekend    | BOOLEAN     | TRUE for Saturday and Sunday                 |
| is_holiday    | BOOLEAN     | TRUE for South African public holidays       |

## dim_product

Product master with category hierarchy.

| Column       | Type           | Description                                |
| ------------ | -------------- | ------------------------------------------ |
| product_key  | INT (PK)       | Surrogate key                              |
| product_code | VARCHAR(20)    | Business identifier (e.g. ELEC-001)        |
| product_name | VARCHAR(150)   | Display name                               |
| category     | VARCHAR(50)    | Top-level category (Electronics, Apparel, Home, Beauty) |
| subcategory  | VARCHAR(50)    | Second-level grouping                      |
| brand        | VARCHAR(50)    | Brand name                                 |
| unit_cost    | DECIMAL(10,2)  | Cost of goods sold (ZAR)                   |
| unit_price   | DECIMAL(10,2)  | Standard list price (ZAR)                  |
| is_active    | BOOLEAN        | Currently in catalogue                     |

## dim_store

Store master with location and size attributes.

| Column         | Type         | Description                                |
| -------------- | ------------ | ------------------------------------------ |
| store_key      | INT (PK)     | Surrogate key                              |
| store_code     | VARCHAR(10)  | Business identifier (e.g. JHB-001)         |
| store_name     | VARCHAR(100) | Display name (e.g. Sandton City)           |
| province       | VARCHAR(50)  | South African province                     |
| city           | VARCHAR(50)  | City                                       |
| store_type     | VARCHAR(30)  | Flagship, Standard, or Express             |
| open_date      | DATE         | Date the store opened                      |
| floor_size_m2  | INT          | Floor size in square metres                |

## dim_customer

Customer master with demographics and loyalty.

| Column         | Type         | Description                                       |
| -------------- | ------------ | ------------------------------------------------- |
| customer_key   | INT (PK)     | Surrogate key                                     |
| customer_code  | VARCHAR(20)  | Business identifier (e.g. CUST-00001)             |
| first_name     | VARCHAR(50)  | First name                                        |
| last_name      | VARCHAR(50)  | Last name                                         |
| email          | VARCHAR(100) | Contact email (synthetic for this dataset)        |
| age_group      | VARCHAR(20)  | 18-24, 25-34, 35-44, 45-54, 55+                   |
| gender         | VARCHAR(10)  | M or F                                            |
| loyalty_tier   | VARCHAR(20)  | Bronze, Silver, Gold, or Platinum                 |
| signup_date    | DATE         | Date customer joined the loyalty programme        |

---

## Notes on data

- All monetary values are in South African Rand (ZAR).
- Customer data is synthetically generated; no real personal information is included.
- The dataset simulates a 3-year window (2022-2024) of retail operations.
