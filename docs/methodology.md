# Methodology

How this project was built, from blank database to dashboards.

## 1. Discovery & business understanding

I started by interviewing fictional stakeholders (CFO, head of merchandising, store ops lead) to define what they needed to see. The 15 questions in [`business-questions.md`](business-questions.md) came directly out of those conversations.

This step matters because it forces analysis to start from "what decisions will this drive?" rather than "what data do we have?".

## 2. Data modelling — star schema

I chose a **star schema** for three reasons:

1. **Query performance** — joins between a single fact table and a few dimension tables are fast and predictable.
2. **Power BI compatibility** — Power BI's relationship model is built around star schemas. Performance and DAX simplicity both improve significantly.
3. **Business intelligibility** — non-technical stakeholders can read and understand a star schema diagram in minutes.

The model has:
- **1 fact table** (`fact_sales`) at the line-item grain
- **4 dimension tables** (`dim_date`, `dim_product`, `dim_store`, `dim_customer`)

Grain decision: I chose **line-item grain** rather than transaction grain so that we can analyse product mix per basket. A trade-off — more rows, but far more analytical flexibility.

See [`../images/erd_diagram.png`](../images/erd_diagram.png) for the full ERD.

## 3. Database build (SQL)

Built in PostgreSQL. The build is split into four scripts so it's idempotent and easy to re-run:

| Script                    | Purpose                                             |
| ------------------------- | --------------------------------------------------- |
| `01_create_schema.sql`    | DROP IF EXISTS, then CREATE TABLE for all tables and indexes |
| `02_seed_data.sql`        | Small sample data for testing the model             |
| `03_generate_data.sql`    | Generates ~50,000 sales transactions across 3 years |
| `04_analysis_queries.sql` | The 10 SQL queries that answer the business questions |

Key technical choices:
- **Surrogate keys (`*_key`)** rather than business keys for joins — protects the model when source identifiers change.
- **Indexes on every foreign key** in the fact table — analytical queries scan large fact tables and join to small dimensions, so foreign-key indexes are essential.
- **`date_key` as INT (YYYYMMDD)** rather than DATE — a small but meaningful performance win on huge fact tables, and easier for Power BI date-table linking.

## 4. Data validation

Before pushing anything to Power BI, I ran:

- Row-count checks on every table
- Null checks on all foreign keys
- Range checks on dates (no future dates, no dates outside the dimension)
- Total revenue sanity check by year (does it look like real retail growth?)
- Spot-checks on aggregation grain (does `SUM(total_amount)` match `SUM(quantity × unit_price × (1 - discount_pct/100))`?)

If any of these fail, the whole analysis is suspect. They take 10 minutes and save days of debugging downstream.

## 5. Power BI modelling

In Power BI Desktop:

1. Connected to the PostgreSQL database via the native connector.
2. Loaded all five tables.
3. Set up relationships matching the ERD (single direction, one-to-many, dimension → fact).
4. Marked `dim_date` as the official Date Table.
5. Built the DAX measures (see [`../powerbi/dax_measures.md`](../powerbi/dax_measures.md)).

## 6. Dashboard design

Two dashboards, each designed for a specific audience:

**Executive Sales Overview** — built for the CFO and CEO. KPIs at the top, trend in the middle, geographic and category breakdowns on the right. The story: are we growing, where, and in what?

**Product Performance Dashboard** — built for buying and merchandising. Top products, category Pareto, and a category × province heatmap to spot gaps and opportunities.

Design principles I followed:
- KPIs first, detail second
- One chart, one question
- Consistent colour (brand green for "good", red for "down" — never both meaning "good" on the same dashboard)
- Mobile/desktop-friendly layouts
- Filters at the top, applied across the page

## 7. What I'd do differently next time

- Add a `dim_promotion` table to track campaigns separately from `discount_pct` — would make marketing ROI analysis much easier.
- Use slowly-changing dimensions (Type 2) on `dim_customer` to track loyalty tier changes over time.
- Add a `fact_inventory` table so we can analyse stock turnover without separate queries.
- Explore time intelligence DAX patterns more deeply — calculation groups would clean up the measures table.
