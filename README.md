# H&M Fashion Commerce BI Platform 
This project is end-to-end fashion commerce analytics platform using H&M public data. 
It combines SQL, Python, Power BI, cloud tools and AI-assisted analytics to support sales, customer, product and recommendation decisions.

## Project Objective

This project transforms the H&M Personalized Fashion Recommendations dataset into a business intelligence platform for customer, sales, product, retention, recommendation, and trend analysis.

The project is also designed as a hands-on learning portfolio to demonstrate practical skills in:

- SQL and PostgreSQL
- Dimensional data modelling
- Python analytics and machine learning
- Power BI dashboard development
- Cloud data warehousing
- AI-assisted business analytics

## Project Roadmap

- [ ] Phase 1 — PostgreSQL data foundation and star schema
- [ ] Phase 2 — SQL analytics views
- [ ] Phase 3 — Customer segmentation and recommendation modelling
- [ ] Phase 4 — Cloud data warehouse
- [ ] Phase 5 — Power BI dashboard
- [ ] Phase 6 — AI business analytics chatbot

## Phase 1: Data Foundation

The original Kaggle CSV files were loaded into a dedicated PostgreSQL raw layer:

- `raw.articles`
- `raw.customers`
- `raw.transactions`

The raw data was then transformed into an analytical star schema:

- `dw.dim_customer`
- `dw.dim_article`
- `dw.dim_date`
- `dw.fact_transactions`

### Fact Table Grain

One row in `dw.fact_transactions` represents one purchased item recorded in the original transaction dataset.

### Dataset Scale

| Table | Rows |
|---|---:|
| `raw.articles` | 105,542 |
| `raw.customers` | 1,371,980 |
| `raw.transactions` | 31,788,324 |
| `dw.dim_article` | 105,542 |
| `dw.dim_customer` | 1,371,980 |
| `dw.dim_date` | 734 |
| `dw.fact_transactions` | 31,788,324 |

