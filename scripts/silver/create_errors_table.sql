--======================================================================================================================================================================
-- SCRIPT: create_errors_table.sql
-- DESCRIPTION: Creates the Silver-layer error quarantine table for CRM Customer Info.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-08
-- NOTES:
-- This table captures invalid or incomplete rows during ETL processing.
-- Typical error cases include:
--   - Missing customer identifiers (CST_ID or CST_KEY)
--   - Missing both ID and name fields
--   - Other data quality issues (to be extended as needed)
--======================================================================================================================================================================

-- Use appropriate role and warehouse for execution
USE ROLE SYSADMIN;
USE WAREHOUSE SALES_WH;

-- Ensure we are in the correct database and schema
USE DATABASE sales_dwh;
USE SCHEMA silver;

--======================================================================================================================================================================
-- TABLE CREATION: CRM_CUST_INFO_ERRORS
-- Rows from Bronze that fail data quality checks are inserted here.
-- Each record includes the original source values plus an error reason for traceability.
--======================================================================================================================================================================

CREATE OR REPLACE TABLE crm_cust_info_errors (
    cst_id NUMBER(38,0) COMMENT 'Customer ID from source (may be NULL if missing)',
    cst_key VARCHAR(50) COMMENT 'Alternative business key (may be NULL if missing)',
    cst_firstname VARCHAR(50) COMMENT 'Customer first name from source',
    cst_lastname VARCHAR(50) COMMENT 'Customer last name from source',
    cst_marital_status VARCHAR(50) COMMENT 'Marital status from source (uncleansed)',
    cst_gndr VARCHAR(50) COMMENT 'Gender from source (uncleansed)',
    cst_create_date DATE COMMENT 'Customer record creation date in source system',
    error_reason VARCHAR(200) COMMENT 'Reason why the record was flagged as invalid',
    dwh_create_date TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp into Silver error table'
)
COMMENT = 'Quarantine table for invalid CRM customer records detected during ETL from Bronze to Silver.';

-- End of script

