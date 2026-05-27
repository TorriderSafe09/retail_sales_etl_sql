# Retail ETL Pipeline

## Project Overview
Retail ETL Pipeline is a SQL-based data engineering project built with MySQL. The project simulates a complete ETL workflow for a retail business, starting from raw transactional data and ending with analytical views, stored procedures, monitoring logs, and audit triggers.
The objective of this project is to demonstrate practical ETL concepts including:
- Raw data ingestion
- Data cleansing and staging
- Relational core model creation
- Analytical reporting views
- ETL monitoring
- Incremental loading
- Stored procedures
- Data validation triggers
- Audit tracking


# Technologies Used

- MySQL
- SQL
- MySQL Workbench
- Git
- GitHub


# project_architecture

The following file shows both the ETL workflow and the project structure

see: docs/project_architecture.md


# ETL Architecture Diagram

The following diagram represents the complete ETL workflow and project architecture.

see: docs/retail_etl_architecture.png


# Screenshots

The following folder contains the operation screenshots and validation tests

see: docs/screenshots


# How to Run the Project

1. Open MySQL Workbench.
2. Execute the SQL scripts in numerical order.
3. Run validations after each module.
4. Execute stored procedures and triggers tests.
5. Review analytical views and ETL logs.

Execution order:

    01_create_database.sql
    02_raw_tables.sql
    03_load_raw_data.sql
    04_staging.sql
    05_core_tables.sql
    06_Views.sql
    07_etl_log.sql
    08_stored_procedures.sql
    09_triggers.sql


# Key Features
* Complete ETL workflow implementation
* Data cleansing and transformation
* Relational data modeling
* Incremental loading process
* Audit and validation triggers
* Analytical reporting views
* ETL monitoring system
* Modular SQL architecture


# Future Improvements

Possible future enhancements:
* Scheduled ETL execution using MySQL Events
* Additional staging transformations
* Slowly Changing Dimensions (SCD)
* Dashboard integration with Power BI or Tableau
* Data quality metrics
* Performance optimization using indexes


# Author

Hugo Reyes | Digital Business and Virtual Environments Engineer
SQL / Data Engineering Portfolio Project