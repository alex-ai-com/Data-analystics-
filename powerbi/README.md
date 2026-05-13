# Power BI Files

This folder contains the Power BI report file and its supporting documentation.

## Files

- `nova_retail_dashboard.pbix` — the Power BI Desktop file (open with Power BI Desktop)
- `dax_measures.md` — full documentation of every DAX measure used in the report

## How to open the .pbix file

1. Install [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free, Windows only).
2. Open `nova_retail_dashboard.pbix`.
3. When prompted for credentials, point Power BI to your local PostgreSQL instance running the Nova Retail database (see the main README for setup).
4. Click **Refresh** to load the latest data.

## Dashboard pages

1. **Executive Overview** — high-level KPIs and trends for the CFO/CEO
2. **Product Performance** — product-level analysis for buying and merchandising

Screenshots of both pages are in [`../images/`](../images/).
