# DAX Measures

Reference for all DAX measures used in the Power BI dashboards.

Measures are organised by topic. Each measure includes a description and the DAX formula.

---

## Revenue measures

### Total Revenue
```dax
Total Revenue =
SUM ( fact_sales[total_amount] )
```

### Revenue PY (prior year, same period)
```dax
Revenue PY =
CALCULATE (
    [Total Revenue],
    SAMEPERIODLASTYEAR ( dim_date[full_date] )
)
```

### Revenue YoY %
```dax
Revenue YoY % =
DIVIDE (
    [Total Revenue] - [Revenue PY],
    [Revenue PY]
)
```

### Revenue YTD
```dax
Revenue YTD =
TOTALYTD (
    [Total Revenue],
    dim_date[full_date]
)
```

---

## Volume measures

### Units Sold
```dax
Units Sold =
SUM ( fact_sales[quantity] )
```

### Transactions
```dax
Transactions =
DISTINCTCOUNT ( fact_sales[sale_id] )
```

### Avg Order Value
```dax
Avg Order Value =
DIVIDE (
    [Total Revenue],
    [Transactions]
)
```

### Units per Transaction
```dax
Units per Transaction =
DIVIDE (
    [Units Sold],
    [Transactions]
)
```

---

## Margin measures

### COGS
```dax
COGS =
SUMX (
    fact_sales,
    fact_sales[quantity] * RELATED ( dim_product[unit_cost] )
)
```

### Gross Profit
```dax
Gross Profit =
[Total Revenue] - [COGS]
```

### Gross Margin %
```dax
Gross Margin % =
DIVIDE (
    [Gross Profit],
    [Total Revenue]
)
```

---

## Customer measures

### Unique Customers
```dax
Unique Customers =
DISTINCTCOUNT ( fact_sales[customer_key] )
```

### Revenue per Customer
```dax
Revenue per Customer =
DIVIDE (
    [Total Revenue],
    [Unique Customers]
)
```

### Repeat Customer Rate
```dax
Repeat Customer Rate =
VAR Repeat =
    CALCULATE (
        DISTINCTCOUNT ( fact_sales[customer_key] ),
        FILTER (
            VALUES ( fact_sales[customer_key] ),
            CALCULATE ( DISTINCTCOUNT ( fact_sales[sale_id] ) ) > 1
        )
    )
RETURN
    DIVIDE ( Repeat, [Unique Customers] )
```

---

## Ranking measures

### Product Rank by Revenue
```dax
Product Rank =
RANKX (
    ALL ( dim_product[product_name] ),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```

### Top 10 Product Filter
```dax
Top 10 Products =
IF (
    [Product Rank] <= 10,
    [Total Revenue],
    BLANK ()
)
```

---

## Discount and pricing

### Discount Amount
```dax
Discount Amount =
SUMX (
    fact_sales,
    fact_sales[quantity] * fact_sales[unit_price] * ( fact_sales[discount_pct] / 100 )
)
```

### Avg Discount %
```dax
Avg Discount % =
AVERAGE ( fact_sales[discount_pct] )
```

---

## Notes

- All measures live in a dedicated `_Measures` table to keep the model tidy.
- Time intelligence measures rely on `dim_date` being marked as the date table.
- For RANKX measures, ensure the visualisation uses the correct dimension column or rankings will collapse.
