# Project Architecture

retail-etl/
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_raw_tables.sql
│   ├── 03_load_raw_data.sql
│   ├── 04_staging.sql
│   ├── 05_core_tables.sql
│   ├── 06_views.sql
│   ├── 07_etl_log.sql
│   ├── 08_stored_procedures.sql
│   └── 09_triggers.sql
│
├── docs/
│   ├── retail_etl_architecture.png
│   └── screenshots/
│
└── README.md

## Raw Layer

Contains the source tables: 
- raw_customers
- raw_products
- raw_orders
- raw_order_items

Purpose:
Store incoming data in its original format before any transformation is applied.

## Staging Layer

Contains:
- stg_customers

Transformations:
- Trim leading and trailing spaces from customer names.
- Replace NULL emails with a default value.

Purpose:
Perform data cleansing before loading records into the core model.

## Core Layer

Contains:
- customers
- products
- orders
- order_items

Purpose:
Store clean and structured business data using relational integrity constraints.

## Analytics Layer

Views:
- vw_sales_by_customer
- vw_sales_by_country
- vw_top_products

Purpose:
Provide aggregated business metrics for reporting and analysis.

## Stored Procedures Layer

Procedures:
- sp_customer_count
- sp_sales_by_country
- sp_log_customer_load
- sp_load_new_customers

Purpose:
Automate ETL operations, incremental loads and analytical queries.

## Monitoring Layer

Table:
- etl_log

Purpose:
Track ETL executions, processed rows, and execution status.

## Audit & Validation Layer

Triggers:
- trg_customer_insert
- trg_customer_update
- trg_validate_quantity

Audit tables:
- audit_customers
- audit_customer_updates

Purpose:
Monitor data changes and enforce business validation rules.