# Data Quality Notes

This dataset is synthetic, but it has been intentionally seeded with realistic data quality issues — the kind you'd encounter on any real retail data project. Part of the value of this project is showing how to find, document, and handle them before they reach the dashboard.

## TL;DR — issues at a glance

| Category               | Issue                                            | Affected rows | Severity |
| ---------------------- | ------------------------------------------------ | ------------- | -------- |
| Referential integrity  | Orphan `customer_key` in `fact_sales`            | ~12           | Medium   |
| Duplicates             | Duplicate `sale_id` rows in `fact_sales`         | ~8            | High     |
| Range violations       | Negative `quantity` (returns mixed into sales)   | ~25           | Medium   |
| Range violations       | `discount_pct` outside the valid 0-100 range     | ~5            | High     |
| Completeness           | Missing `email` in `dim_customer`                | ~250 (5%)     | Low      |
| Consistency            | Inconsistent name casing in `dim_customer`       | ~150 (3%)     | Low      |
| Consistency            | Leading/trailing whitespace in `dim_customer`    | ~100 (2%)     | Low      |

## How to find each issue

These queries will surface every problem listed above. They live in `sql/05_data_quality_checks.sql` and form the validation step before any analysis runs.

### 1. Orphan foreign keys

A `customer_key` in `fact_sales` that doesn't exist in `dim_customer` will silently break customer-level analysis.

```sql
SELECT DISTINCT f.customer_key
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;
```

**Decision:** route these rows to a quarantine table; flag for the source-system owner; exclude from customer-cohort reports until resolved.

### 2. Duplicate sale_ids

A primary key should be unique. Duplicates inflate every downstream metric.

```sql
SELECT sale_id, COUNT(*) AS occurrences
FROM fact_sales
GROUP BY sale_id
HAVING COUNT(*) > 1;
```

**Decision:** deduplicate using `ROW_NUMBER()` partitioned by `sale_id`, keeping the first occurrence. Investigate whether the duplication is a load-process bug or a true business event (rare).

### 3. Negative quantities

Returns mixed into the sales table without a clear flag. Either separate them out or flip the sign on the corresponding amount.

```sql
SELECT *
FROM fact_sales
WHERE quantity < 0;
```

**Decision:** treat negative quantities as returns. Either filter them out for "gross sales" reporting or include them for "net sales" reporting — but be explicit about which one you're showing.

### 4. Out-of-range discount percentages

A discount above 100 means we paid the customer to take the item. A discount below 0 doesn't exist.

```sql
SELECT *
FROM fact_sales
WHERE discount_pct < 0 OR discount_pct > 100;
```

**Decision:** quarantine and investigate. These are almost always data-entry or load errors and should never reach a dashboard.

### 5. Missing emails

Not every customer signed up with an email — the loyalty programme allowed phone-only signups.

```sql
SELECT COUNT(*) AS missing_email_count
FROM dim_customer
WHERE email IS NULL OR TRIM(email) = '';
```

**Decision:** acceptable. Document it. Don't suppress these customers from analysis — they're real customers, just missing one optional attribute.

### 6. Inconsistent casing

`Thandi` and `THANDI` and `thandi` should not be treated as different people.

```sql
-- Names that contain only uppercase or only lowercase letters
SELECT customer_key, first_name, last_name
FROM dim_customer
WHERE first_name = UPPER(first_name)
   OR first_name = LOWER(first_name)
   OR last_name = UPPER(last_name)
   OR last_name = LOWER(last_name);
```

**Decision:** standardise to title case during ETL using `INITCAP()` or its equivalent. Do this once at load time, not in every downstream query.

### 7. Leading and trailing whitespace

`'  Thandi'` and `'Thandi'` will join differently and group separately.

```sql
SELECT customer_key, first_name, last_name
FROM dim_customer
WHERE first_name <> TRIM(first_name)
   OR last_name <> TRIM(last_name);
```

**Decision:** apply `TRIM()` to all string columns at load time.

## The fix-or-flag framework

For every data quality issue, decide one of three things:

1. **Fix it at the source.** The right answer when the issue is a load-process or system bug. Costs more upfront, saves rework forever.
2. **Fix it in the pipeline.** Acceptable for issues that can be cleanly handled in transformation (casing, trimming, type casting).
3. **Flag it and live with it.** Right answer when the data reflects messy reality (missing emails, returns mixed in). Document the decision and the impact.

Avoid the fourth option — fixing it silently in a single query — because the fix doesn't carry over to the next query, the next analyst, or the next dashboard.

## What the dashboards do

For this project:

- Orphan customer_keys → excluded from customer cohort analyses; included in revenue totals (the sales still happened, we just don't know to whom).
- Duplicates → deduplicated in the staging step before Power BI loads.
- Negative quantities → kept; reported as "net sales" with a note in the dashboard tooltip.
- Out-of-range discounts → excluded from analysis; quarantined for manual review.
- Missing emails / casing / whitespace → cleaned in the staging layer with `TRIM()` and `INITCAP()`.

This isn't the only valid set of choices — but they're documented, defensible, and consistent across every visual on every dashboard.
