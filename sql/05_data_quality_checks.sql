-- =============================================================================
-- Nova Retail Group | Data Quality Checks
-- =============================================================================
-- Description: Surface every data quality issue documented in docs/data-quality.md
-- Run these checks BEFORE any analytical query or dashboard refresh.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- CHECK 1: Orphan foreign keys (customer_key in fact_sales not in dim_customer)
-- -----------------------------------------------------------------------------
SELECT
    'Orphan customer_keys' AS check_name,
    COUNT(*)               AS issue_count
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Show the actual orphans
SELECT DISTINCT f.customer_key
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- -----------------------------------------------------------------------------
-- CHECK 2: Duplicate sale_ids
-- -----------------------------------------------------------------------------
SELECT
    'Duplicate sale_ids' AS check_name,
    COUNT(*)             AS issue_count
FROM (
    SELECT sale_id
    FROM fact_sales
    GROUP BY sale_id
    HAVING COUNT(*) > 1
) dupes;

-- Show the duplicates
SELECT sale_id, COUNT(*) AS occurrences
FROM fact_sales
GROUP BY sale_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- -----------------------------------------------------------------------------
-- CHECK 3: Negative quantities (returns mixed into sales)
-- -----------------------------------------------------------------------------
SELECT
    'Negative quantities' AS check_name,
    COUNT(*)              AS issue_count
FROM fact_sales
WHERE quantity < 0;


-- -----------------------------------------------------------------------------
-- CHECK 4: Out-of-range discounts
-- -----------------------------------------------------------------------------
SELECT
    'Out-of-range discounts' AS check_name,
    COUNT(*)                 AS issue_count
FROM fact_sales
WHERE discount_pct < 0 OR discount_pct > 100;

-- Show the offenders
SELECT sale_id, discount_pct
FROM fact_sales
WHERE discount_pct < 0 OR discount_pct > 100
ORDER BY discount_pct DESC;


-- -----------------------------------------------------------------------------
-- CHECK 5: Missing emails
-- -----------------------------------------------------------------------------
SELECT
    'Missing emails' AS check_name,
    COUNT(*)         AS issue_count
FROM dim_customer
WHERE email IS NULL OR TRIM(email) = '';


-- -----------------------------------------------------------------------------
-- CHECK 6: Inconsistent casing in customer names
-- -----------------------------------------------------------------------------
SELECT
    'Casing issues' AS check_name,
    COUNT(*)        AS issue_count
FROM dim_customer
WHERE first_name = UPPER(first_name)
   OR first_name = LOWER(first_name)
   OR last_name  = UPPER(last_name)
   OR last_name  = LOWER(last_name);


-- -----------------------------------------------------------------------------
-- CHECK 7: Leading or trailing whitespace
-- -----------------------------------------------------------------------------
SELECT
    'Whitespace issues' AS check_name,
    COUNT(*)            AS issue_count
FROM dim_customer
WHERE first_name <> TRIM(first_name)
   OR last_name  <> TRIM(last_name);


-- -----------------------------------------------------------------------------
-- CHECK 8: total_amount sanity check
-- -----------------------------------------------------------------------------
-- Does the line total match quantity × unit_price × (1 - discount_pct/100)?
SELECT
    'total_amount calculation mismatches' AS check_name,
    COUNT(*) AS issue_count
FROM fact_sales
WHERE ROUND(total_amount, 2) <>
      ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2)
  AND discount_pct BETWEEN 0 AND 100   -- exclude bad discounts (already captured)
  AND quantity > 0;                     -- exclude negative quantities (already captured)


-- -----------------------------------------------------------------------------
-- CHECK 9: Date keys outside the dim_date range
-- -----------------------------------------------------------------------------
SELECT
    'Sales with date_key outside dim_date' AS check_name,
    COUNT(*) AS issue_count
FROM fact_sales f
LEFT JOIN dim_date d ON f.date_key = d.date_key
WHERE d.date_key IS NULL;


-- -----------------------------------------------------------------------------
-- CHECK 10: Future-dated sales (shouldn't exist)
-- -----------------------------------------------------------------------------
SELECT
    'Future-dated sales' AS check_name,
    COUNT(*)             AS issue_count
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.full_date > CURRENT_DATE;


-- =============================================================================
-- SUMMARY: Run all checks at once
-- =============================================================================
WITH checks AS (
    SELECT 'Orphan customer_keys' AS check_name,
           (SELECT COUNT(*) FROM fact_sales f
            LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
            WHERE c.customer_key IS NULL) AS issue_count
    UNION ALL
    SELECT 'Duplicate sale_ids',
           (SELECT COUNT(*) FROM (
               SELECT sale_id FROM fact_sales GROUP BY sale_id HAVING COUNT(*) > 1
           ) d)
    UNION ALL
    SELECT 'Negative quantities',
           (SELECT COUNT(*) FROM fact_sales WHERE quantity < 0)
    UNION ALL
    SELECT 'Out-of-range discounts',
           (SELECT COUNT(*) FROM fact_sales WHERE discount_pct < 0 OR discount_pct > 100)
    UNION ALL
    SELECT 'Missing emails',
           (SELECT COUNT(*) FROM dim_customer WHERE email IS NULL OR TRIM(email) = '')
    UNION ALL
    SELECT 'Casing issues',
           (SELECT COUNT(*) FROM dim_customer
            WHERE first_name = UPPER(first_name) OR first_name = LOWER(first_name)
               OR last_name  = UPPER(last_name)  OR last_name  = LOWER(last_name))
    UNION ALL
    SELECT 'Whitespace issues',
           (SELECT COUNT(*) FROM dim_customer
            WHERE first_name <> TRIM(first_name) OR last_name <> TRIM(last_name))
)
SELECT
    check_name,
    issue_count,
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'REVIEW' END AS status
FROM checks
ORDER BY issue_count DESC;
