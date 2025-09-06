
--======================================================================================================================================================================
-- SCRIPT: setup_sales_dwh.sql
-- DESCRIPTION: Sets up the initial database and schema structure for a sales data warehouse in Snowflake.
-- AUTHOR: Pedro Daim
-- CREATION DATE: 2025-09-06
-- NOTES:
-- This script creates a single database with a multi-layered schema architecture
-- (bronze, silver, gold) to support a modern data warehouse design.
-- Before running, ensure you have the necessary permissions for database creation.
--======================================================================================================================================================================
--
-- Use the appropriate role and warehouse for execution.
-- A role with the CREATE DATABASE privilege is required (e.g., ACCOUNTADMIN or SYSADMIN).
USE ROLE SYSADMIN;
USE WAREHOUSE SALES_WH; 

-- The "CREATE OR REPLACE DATABASE" command is used to ensure the script is idempotent.
-- This means it can be run multiple times without causing an error.
-- Be cautious, as this will drop the database and all its objects if it already exists.
CREATE OR REPLACE DATABASE sales_dwh
COMMENT = 'Centralized data warehouse for sales analytics, following a tiered architecture.';

-- Explicitly use the newly created database for subsequent commands.
USE DATABASE sales_dwh;

-- ======================================================================================================================================================================
-- SCHEMA CREATION
-- We will create a multi-layered architecture to separate different stages of data processing.
-- ======================================================================================================================================================================

-- Bronze Layer (Raw Data)
-- This schema is for raw, unprocessed data ingested from source systems.
-- Data in this layer should be immutable and a direct copy of the source.
-- Bronze Layer: Raw, unprocessed data ingested directly from source systems
CREATE OR REPLACE SCHEMA bronze
COMMENT = 'Bronze Layer: Raw, unprocessed data ingested directly from source systems.';

-- Silver Layer (Staging & Transformation)
-- This schema is for cleansed, conformed, and transformed data.
-- Data here is ready for initial analysis and building business views.
CREATE OR REPLACE SCHEMA silver
COMMENT = 'Silver Layer: Staging and transformation layer for cleansed and enriched data.';

-- Gold Layer (Business Views & Reporting)
-- This schema is for highly-curated, aggregated data models optimized for reporting and analytics.
-- This is the layer that business users and BI tools will primarily access.
CREATE OR REPLACE SCHEMA gold
COMMENT = 'Gold Layer: Curated and aggregated data models optimized for reporting and analytics.';

-- ======================================================================================================================================================================
-- SECURITY: GRANT PRIVILEGES
-- Granting necessary privileges to a specific role is a critical security best practice.
-- This ensures that users can interact with the database and its objects.
--======================================================================================================================================================================
--
GRANT USAGE ON DATABASE sales_dwh TO ROLE SYSADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE sales_dwh TO ROLE SYSADMIN;
GRANT SELECT ON ALL TABLES IN DATABASE sales_dwh TO ROLE SYSADMIN;

-- End of script
