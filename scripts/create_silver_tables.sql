-- ====================================================================================================================================
-- SCRIPT: create_silver_tables.sql
-- DESCRIPTION: Creates the tables for the silver layer of the sales data warehouse in Snowflake.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-07
-- NOTES:
-- This script is idempotent, meaning it can be run multiple times without error.
-- It will drop and recreate tables to ensure the schema is always up-to-date.
-- All string data types are defined as VARCHAR, as Snowflake natively supports Unicode.
-- This script is a copy of the create_bronze_tables.sql file found in the scripts folder on this repo. Now all tables include a 'dwh_create_date' column to track data ingestion into the silver layer.
-- ====================================================================================================================================

-- Ensure use of the correct database and schema before running.
USE DATABASE sales_dwh;
USE SCHEMA silver;

-- ====================================================================================================================================
-- TABLE CREATION
-- The CREATE OR REPLACE TABLE command is used to be idempotent.
-- This ensures the script is repeatable and safe to run in a CI/CD pipeline.
-- ====================================================================================================================================

-- Table: crm_cust_info
-- Source: CRM system customer information
CREATE OR REPLACE TABLE crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
COMMENT ON TABLE crm_cust_info IS 'Added a create_date column to the raw crm customer table from the bronze layer';

-- Table: crm_prd_info
-- Source: CRM system product information
CREATE OR REPLACE TABLE SALES_DWH.SILVER.CRM_PRD_INFO (
	PRD_ID NUMBER(38,0),
    CAT_ID VARCHAR(50),
	PRD_KEY VARCHAR(50),
	PRD_NM VARCHAR(50),
	PRD_COST NUMBER(10,2),
	PRD_LINE VARCHAR(50),
	PRD_START_DT DATE,
	PRD_END_DT DATE,
	DWH_CREATE_DATE TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
)COMMENT='Copy from the raw crm_prd_info table from the bronze layer with a cat_id column and new datatype for the prd_start_dt and prd_end_dt because there is no need for timestamps since the original data only has 00:00:00 as values '
;

-- Table: crm_sales_details
-- Source: CRM system sales transaction details
CREATE OR REPLACE TABLE crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE, 
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    NUMBER(10, 2), 
    sls_price    NUMBER(10, 2),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
COMMENT ON TABLE crm_sales_details IS 'Added a create_date column to the raw crm transaction table from the bronze layer';

-- Table: erp_loc_a101
-- Source: ERP system location data
CREATE OR REPLACE TABLE erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
COMMENT ON TABLE erp_loc_a101 IS 'Added a create_date column to the raw erp location table from the bronze layer';

-- Table: erp_cust_az12
-- Source: ERP system customer demographic data
CREATE OR REPLACE TABLE erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
COMMENT ON TABLE erp_cust_az12 IS 'Added a create_date column to the raw erp customer demographics table from the bronze layer';

-- Table: erp_px_cat_g1v2
-- Source: ERP system product category data
CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
COMMENT ON TABLE erp_px_cat_g1v2 IS 'Added a create_date column to the raw erp product category table from the bronze layer';

-- End of script
