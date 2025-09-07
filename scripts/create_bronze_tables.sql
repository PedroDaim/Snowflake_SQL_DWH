-- ====================================================================================================================================
-- SCRIPT: create_bronze_tables.sql
-- DESCRIPTION: Creates the tables for the bronze layer of the sales data warehouse in Snowflake.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-06
-- NOTES:
-- This script is idempotent, meaning it can be run multiple times without error.
-- It will drop and recreate tables to ensure the schema is always up-to-date.
-- All string data types are defined as VARCHAR, as Snowflake natively supports Unicode.
-- ====================================================================================================================================

-- Ensure use of the correct database and schema before running.
USE DATABASE sales_dwh;
USE SCHEMA bronze;

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
    cst_create_date    DATE
);
COMMENT ON TABLE crm_cust_info IS 'Raw customer information from the CRM system.';

-- Table: crm_prd_info
-- Source: CRM system product information
CREATE OR REPLACE TABLE crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     NUMBER(10, 2), 
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP_NTZ, 
    prd_end_dt   TIMESTAMP_NTZ
);
COMMENT ON TABLE crm_prd_info IS 'Raw product information from the CRM system.';

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
    sls_quantity NUMBER,
    sls_price    NUMBER(10, 2)
);
COMMENT ON TABLE crm_sales_details IS 'Raw sales transaction details from the CRM system.';

-- Table: erp_loc_a101
-- Source: ERP system location data
CREATE OR REPLACE TABLE erp_loc_a101 (
    cid   VARCHAR(50),
    cntry VARCHAR(50)
);
COMMENT ON TABLE erp_loc_a101 IS 'Raw location data from the ERP system.';

-- Table: erp_cust_az12
-- Source: ERP system customer demographic data
CREATE OR REPLACE TABLE erp_cust_az12 (
    cid   VARCHAR(50),
    bdate DATE,
    gen   VARCHAR(50)
);
COMMENT ON TABLE erp_cust_az12 IS 'Raw customer demographics from the ERP system.';

-- Table: erp_px_cat_g1v2
-- Source: ERP system product category data
CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50)
);
COMMENT ON TABLE erp_px_cat_g1v2 IS 'Raw product category data from the ERP system.';

-- End of script
