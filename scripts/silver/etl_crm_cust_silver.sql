--======================================================================================================================================================================
-- SCRIPT: etl_crm_cust_silver.sql
-- DESCRIPTION: ETL process for Silver layer CRM Customer Info in Snowflake.
--              Deduplicates, validates, generates metrics, and populates Silver tables.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-08
-- NOTES:
--   - Bronze table: raw source CRM data
--   - Silver tables: cleansed/validated data, error quarantine, and metrics
--======================================================================================================================================================================

-- Use appropriate role and warehouse
USE ROLE SYSADMIN;
USE WAREHOUSE SALES_WH;

-- Ensure correct database and schema
USE DATABASE sales_dwh;
USE SCHEMA silver;

--======================================================================================================================================================================
-- STEP 0: Truncate Silver tables to prevent duplicates on re-runs
--======================================================================================================================================================================

TRUNCATE TABLE silver.crm_cust_info;
TRUNCATE TABLE silver.crm_cust_info_errors;
TRUNCATE TABLE silver.crm_cust_info_metrics;

--======================================================================================================================================================================
-- STEP 1: Deduplicate by CST_ID (latest record per customer)
--======================================================================================================================================================================

CREATE OR REPLACE TEMPORARY TABLE tmp_deduped_id AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn_id
    FROM bronze.crm_cust_info
) t
WHERE rn_id = 1;

--======================================================================================================================================================================
-- STEP 2: Deduplicate by CST_KEY for rows where CST_ID is NULL
--======================================================================================================================================================================

CREATE OR REPLACE TEMPORARY TABLE tmp_deduped_key AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_key ORDER BY cst_create_date DESC) AS rn_key
    FROM bronze.crm_cust_info
    WHERE cst_id IS NULL AND cst_key IS NOT NULL
) t
WHERE rn_key = 1;

--======================================================================================================================================================================
-- STEP 3: Combine deduplicated sets into valid customers
--           Prevent overlap: only include keys not already in tmp_deduped_id
--======================================================================================================================================================================

CREATE OR REPLACE TEMPORARY TABLE tmp_valid_customers AS
SELECT * FROM tmp_deduped_id
UNION
SELECT * 
FROM tmp_deduped_key k
WHERE k.cst_key NOT IN (
    SELECT cst_key FROM tmp_deduped_id WHERE cst_key IS NOT NULL
);

--======================================================================================================================================================================
-- STEP 4: Identify error rows (missing critical identifiers)
--======================================================================================================================================================================

CREATE OR REPLACE TEMPORARY TABLE tmp_errors AS
SELECT *,
       'Missing CST_ID and/or Name fields' AS error_reason
FROM bronze.crm_cust_info
WHERE (cst_id IS NULL AND cst_key IS NULL)
   OR (cst_id IS NULL AND cst_firstname IS NULL AND cst_lastname IS NULL);

--======================================================================================================================================================================
-- STEP 5: Generate metrics
--======================================================================================================================================================================

CREATE OR REPLACE TEMPORARY TABLE tmp_metrics AS
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN cst_id IS NULL THEN 1 END) AS missing_cst_id,
    COUNT(CASE WHEN cst_key IS NULL THEN 1 END) AS missing_cst_key,
    COUNT(CASE WHEN (cst_id IS NULL AND cst_key IS NULL)
               OR (cst_id IS NULL AND cst_firstname IS NULL AND cst_lastname IS NULL)
         THEN 1 END) AS missing_all_identifiers_or_names,
    COUNT(CASE WHEN cst_gndr IS NULL OR TRIM(cst_gndr) = '' THEN 1 END) AS missing_gender,
    (
        SELECT COUNT(*) 
        FROM (
            SELECT cst_id 
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
            GROUP BY cst_id
            HAVING COUNT(*) > 1
        )
    ) AS duplicate_cst_id,
    (
        SELECT COUNT(*) 
        FROM (
            SELECT cst_key 
            FROM bronze.crm_cust_info
            WHERE cst_id IS NULL AND cst_key IS NOT NULL
            GROUP BY cst_key
            HAVING COUNT(*) > 1
        )
    ) AS duplicate_cst_key,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM bronze.crm_cust_info;

--======================================================================================================================================================================
-- STEP 6: Insert into Silver tables
--======================================================================================================================================================================

-- Valid customers
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    dwh_create_date
)
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    CURRENT_TIMESTAMP()
FROM tmp_valid_customers;

-- Errors
INSERT INTO silver.crm_cust_info_errors (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    error_reason,
    dwh_create_date
)
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    NULL AS cst_marital_status,
    cst_gndr,
    NULL AS cst_create_date,
    error_reason,
    CURRENT_TIMESTAMP()
FROM tmp_errors;

-- Metrics
INSERT INTO silver.crm_cust_info_metrics (
    total_rows,
    missing_cst_id,
    missing_cst_key,
    missing_all_identifiers_or_names,
    missing_gender,
    duplicate_cst_id,
    duplicate_cst_key,
    load_timestamp
)
SELECT * FROM tmp_metrics;

--======================================================================================================================================================================
-- STEP 7: Log Row Counts 
--======================================================================================================================================================================

-- Valid rows
SELECT COUNT(*) AS valid_rows_inserted
FROM silver.crm_cust_info
WHERE CAST(dwh_create_date AS DATE) = CURRENT_DATE();

-- Error rows
SELECT COUNT(*) AS error_rows_inserted
FROM silver.crm_cust_info_errors
WHERE CAST(dwh_create_date AS DATE) = CURRENT_DATE();

-- Metrics row
SELECT COUNT(*) AS metrics_rows_inserted
FROM silver.crm_cust_info_metrics
WHERE CAST(load_timestamp AS DATE) = CURRENT_DATE();

-- End of script
