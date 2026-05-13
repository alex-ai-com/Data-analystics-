-- =============================================================================
-- Nova Retail Group | Business Analysis Queries
-- =============================================================================
-- Description: Answers to the business questions defined in docs/business-questions.md
-- These queries form the basis of the Power BI dashboards.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Q1. What is total revenue and YoY growth?
-- -----------------------------------------------------------------------------
WITH yearly_revenue AS (
    SELECT
        d.year,
        SUM(f.total_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year
)
SELECT
    year,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY year) AS prior_year_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY year), 0) * 100,
        2
    ) AS yoy_growth_pct
FROM yearly_revenue
ORDER BY year;


-- -----------------------------------------------------------------------------
-- Q2. Top 10 products by revenue (current year)
-- -----------------------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    p.brand,
    SUM(f.quantity)        AS units_sold,
    SUM(f.total_amount)    AS total_revenue,
    AVG(f.unit_price)      AS avg_selling_price,
    ROUND(
        SUM(f.total_amount) * 100.0
        / SUM(SUM(f.total_amount)) OVER (),
        2
    ) AS revenue_share_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d    ON f.date_key    = d.date_key
WHERE d.year = 2024
GROUP BY p.product_name, p.category, p.brand
ORDER BY total_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q3. Revenue by province with store count
-- -----------------------------------------------------------------------------
SELECT
    s.province,
    COUNT(DISTINCT s.store_key)              AS store_count,
    SUM(f.total_amount)                      AS total_revenue,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT s.store_key), 2) AS revenue_per_store,
    SUM(f.quantity)                          AS units_sold
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d  ON f.date_key  = d.date_key
WHERE d.year = 2024
GROUP BY s.province
ORDER BY total_revenue DESC;


-- -----------------------------------------------------------------------------
-- Q4. Monthly revenue trend (used for the line chart)
-- -----------------------------------------------------------------------------
SELECT
    d.year,
    d.month_number,
    d.month_name,
    SUM(f.total_amount)                                AS revenue,
    SUM(f.quantity)                                    AS units,
    COUNT(DISTINCT f.sale_id)                          AS transactions,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.sale_id), 2) AS avg_basket_value
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_number, d.month_name
ORDER BY d.year, d.month_number;


-- -----------------------------------------------------------------------------
-- Q5. Customer segmentation by loyalty tier
-- -----------------------------------------------------------------------------
SELECT
    c.loyalty_tier,
    COUNT(DISTINCT c.customer_key)             AS customer_count,
    COUNT(DISTINCT f.sale_id)                  AS total_transactions,
    SUM(f.total_amount)                        AS total_revenue,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT c.customer_key), 2) AS revenue_per_customer,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.sale_id), 2)      AS avg_basket
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.loyalty_tier
ORDER BY revenue_per_customer DESC;


-- -----------------------------------------------------------------------------
-- Q6. Category performance (Pareto analysis — used in dashboard)
-- -----------------------------------------------------------------------------
WITH category_revenue AS (
    SELECT
        p.category,
        SUM(f.total_amount) AS revenue
    FROM fact_sales f
    JOIN dim_product p ON f.product_key = p.product_key
    JOIN dim_date d    ON f.date_key    = d.date_key
    WHERE d.year = 2024
    GROUP BY p.category
)
SELECT
    category,
    revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS revenue_share_pct,
    ROUND(
        SUM(revenue) OVER (ORDER BY revenue DESC) * 100.0
        / SUM(revenue) OVER (),
        2
    ) AS cumulative_share_pct
FROM category_revenue
ORDER BY revenue DESC;


-- -----------------------------------------------------------------------------
-- Q7. Sales heatmap — Category × Province
-- -----------------------------------------------------------------------------
SELECT
    p.category,
    s.province,
    SUM(f.total_amount)  AS revenue,
    SUM(f.quantity)      AS units_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s   ON f.store_key   = s.store_key
JOIN dim_date d    ON f.date_key    = d.date_key
WHERE d.year = 2024
GROUP BY p.category, s.province
ORDER BY p.category, revenue DESC;


-- -----------------------------------------------------------------------------
-- Q8. Discount impact analysis
-- -----------------------------------------------------------------------------
SELECT
    CASE
        WHEN f.discount_pct = 0  THEN '0% (no discount)'
        WHEN f.discount_pct <= 10 THEN '1-10%'
        WHEN f.discount_pct <= 20 THEN '11-20%'
        ELSE '20%+'
    END AS discount_band,
    COUNT(DISTINCT f.sale_id)                AS transactions,
    SUM(f.quantity)                          AS units_sold,
    SUM(f.total_amount)                      AS revenue,
    ROUND(AVG(f.total_amount), 2)            AS avg_transaction_value
FROM fact_sales f
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN '0% (no discount)' THEN 1
        WHEN '1-10%'  THEN 2
        WHEN '11-20%' THEN 3
        ELSE 4
    END;


-- -----------------------------------------------------------------------------
-- Q9. Store performance ranking
-- -----------------------------------------------------------------------------
SELECT
    s.store_name,
    s.province,
    s.store_type,
    SUM(f.total_amount)                              AS revenue,
    SUM(f.quantity)                                  AS units,
    COUNT(DISTINCT f.sale_id)                        AS transactions,
    COUNT(DISTINCT f.customer_key)                   AS unique_customers,
    RANK() OVER (ORDER BY SUM(f.total_amount) DESC)  AS revenue_rank
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d  ON f.date_key  = d.date_key
WHERE d.year = 2024
GROUP BY s.store_name, s.province, s.store_type
ORDER BY revenue DESC;


-- -----------------------------------------------------------------------------
-- Q10. Repeat customer rate
-- -----------------------------------------------------------------------------
WITH customer_transactions AS (
    SELECT
        f.customer_key,
        COUNT(DISTINCT f.sale_id) AS transaction_count
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.year = 2024
    GROUP BY f.customer_key
)
SELECT
    CASE
        WHEN transaction_count = 1     THEN 'One-time'
        WHEN transaction_count BETWEEN 2 AND 5  THEN 'Occasional (2-5)'
        WHEN transaction_count BETWEEN 6 AND 10 THEN 'Regular (6-10)'
        ELSE 'Loyal (10+)'
    END AS customer_segment,
    COUNT(*)  AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_base
FROM customer_transactions
GROUP BY customer_segment
ORDER BY
    CASE customer_segment
        WHEN 'One-time'        THEN 1
        WHEN 'Occasional (2-5)' THEN 2
        WHEN 'Regular (6-10)'   THEN 3
        ELSE 4
    END;
