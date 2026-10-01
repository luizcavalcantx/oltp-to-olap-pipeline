# E-commerce Data Warehouse: PostgreSQL to Snowflake (dbt Modeling)

OLTP-to-OLAP data pipeline: PostgreSQL to Snowflake, with dimensional modeling and SQL-based data transformations using dbt.

## Objective

This project simulates a real-world analytics engineering workflow: an e-commerce business runs its day-to-day operations on a transactional database, and that data needs to be extracted, cleaned, and remodeled into a dimensional model for reporting.

The core (and final) focus of this project is **data modeling with dbt**: transforming a normalized OLTP source into a denormalized star-schema OLAP model on Snowflake, using SQL and dbt best practices (staging, intermediate, and mart layers, testing, and documentation). Extraction exists only to feed that modeling work. Orchestration (Airflow) and a downstream BI tool are out of scope — the project is scoped to end at the dbt-modeled star schema in Snowflake.

## Architecture

```mermaid
flowchart LR
    subgraph op[Operational layer]
        A[OLTP Database\nPostgres]
    end
    subgraph pipeline[Pipeline & analytical layer]
        B[Extraction\nBatch]
        C[Data Lake / Staging\nS3 - raw files]
        D[Transformation\ndbt: staging, intermediate & marts]
        E[Snowflake OLAP\nStar schema]
    end
    A --> B --> C --> D --> E
```

**Flow:**

1. **OLTP Database (PostgreSQL)** — normalized transactional source, simulating the operational database of an e-commerce platform (orders, customers, products, payments, etc.).
2. **Extraction** ✅ — Python scripts extract the raw Olist tables from Postgres, convert them to Parquet, and upload them to S3 (`data_to_s3/`).
3. **Data lake / staging** ✅ — raw Parquet files land in S3 (`s3://olist-oltp-olap/raw/`) and are loaded into Snowflake's `bronze` schema via an external stage + `COPY INTO` (`sql/snowflake_setup_olist.sql`).
4. **Transformation (core focus)** ✅ — cleaning, standardization, and dimensional modeling using **dbt** (`dbt-snowflake` adapter), fully built across all three layers, in SQL:
   - **staging** — 9 source-conformed models (`customers`, `geolocation`, `orders`, `order_items`, `order_payments`, `order_reviews`, `products`, `product_category_name_translation`, `sellers`), with column-level documentation and generic tests (`not_null`, `unique`, `relationships`, `accepted_values`).
   - **intermediate** — business-logic aggregations (`int_orders_delivery_metrics`, `int_orders_payments_agg`, `int_orders_reviews_agg`, `int_order_items_enriched`).
   - **marts** — final star schema: dimensions (`dim_customers`, `dim_sellers`, `dim_products`) and facts (`fct_orders`, `fct_order_items`, `fct_payments`, `fct_reviews`), with primary-key and relationship tests.
5. **Snowflake OLAP** — final star-schema model (fact and dimension tables) in the `gold` schema, optimized for analytical queries. `bronze`/`silver`/`gold` schemas and role-based access (`dbt_role`/`dbt_user`) are provisioned (`sql/snowflake_grants.sql`).

## Tech Stack

- **Source database:** PostgreSQL (OLTP)
- **Data warehouse / OLAP layer:** Snowflake
- **Staging storage:** AWS S3 (raw landing zone), loaded via a Snowflake external stage + storage integration
- **Extraction:** Python (`boto3`, `psycopg2`) — Postgres → Parquet → S3
- **Transformation (project focus):** SQL / dbt (`dbt-snowflake` adapter) — staging → intermediate → marts, dimensional modeling, tests, and documentation
- **Containerization:** Docker (local Postgres source)
- **Modeling approach:** Kimball-style dimensional modeling (star schema)

## Status

✅ Project complete, scoped to the dbt-modeled star schema on Snowflake.

- ✅ Postgres → S3 extraction scripts
- ✅ Snowflake setup: database, `bronze`/`silver`/`gold` schemas, external stage, storage integration, role/user grants
- ✅ Raw data loaded into `bronze` via `COPY INTO`
- ✅ dbt staging layer: all 9 source models built, documented, and tested
- ✅ dbt intermediate layer: 4 business-logic models
- ✅ dbt mart layer: star schema (3 dimensions, 4 facts), documented and tested

Not pursued, by scope decision: orchestration (Airflow) and a downstream BI/consumption layer. The project stops at the dbt-modeled star schema in Snowflake.

## Project Structure

```
.
├── data_to_s3/       # Python extraction: Postgres -> Parquet -> S3
├── sql/              # Snowflake setup: database, schemas, stage, tables, grants
├── olist_dbt/        # dbt project (dbt-snowflake): staging, intermediate, and mart models
│   └── models/
│       ├── staging/      # source-conformed models
│       ├── intermediate/ # business logic layer
│       └── marts/        # final star schema (dimensions + facts)
├── docker-compose.yml
└── README.md
```
