--======================================================================================================================================================================
-- SCRIPT: create_metrics_table.sql
-- DESCRIPTION: Creates the metrics table in the Silver schema to store data quality checks for CRM Customer Info.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-08
-- NOTES:
-- This table will store data quality metrics (missing values, duplicates, total counts)
-- as part of the ETL process for the Silver layer in the Medallion architecture.
--======================================================================================================================================================================

-- Use appropriate role and warehouse for execution
USE ROLE SYSADMIN;
USE WAREHOUSE SALES_WH;

-- Ensure we are in the correct database and schema
USE DATABASE sales_dwh;
USE SCHEMA silver;

--======================================================================================================================================================================
-- TABLE CREATION: CRM_CUST_INFO_METRICS
-- This table stores data quality metrics calculated during the ETL process.
-- Each row corresponds to one ETL run, identified by the load timestamp.
--======================================================================================================================================================================

CREATE OR REPLACE TABLE crm_cust_info_metrics (
    total_rows NUMBER COMMENT 'Total number of rows processed from the Bronze layer',
    missing_cst_id NUMBER COMMENT 'Number of rows missing customer ID',
    missing_cst_key NUMBER COMMENT 'Number of rows missing customer key',
    missing_all_identifiers_or_names NUMBER COMMENT 'Rows missing both identifiers or missing ID + name fields',
    missing_gender NUMBER COMMENT 'Number of rows missing gender values',
    duplicate_cst_id NUMBER COMMENT 'Number of duplicate customer IDs found',
    duplicate_cst_key NUMBER COMMENT 'Number of duplicate customer keys found (only when CST_ID is null)',
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp when this metrics record was generated'
)
COMMENT = 'Metrics table for CRM Customer Info. Stores data quality counts for each ETL run.';

-- End of script
