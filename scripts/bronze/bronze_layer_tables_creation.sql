/*
============================================================
BRONZE LAYER – TABLE CREATION SCRIPT
============================================================
Purpose:
    This script (re)creates all tables in the BRONZE schema.
    The bronze layer represents raw, lightly structured data
    ingested from source systems (CRM and ERP).

Behavior:
    - If a table already exists, it is dropped
    - The table is then recreated with a clean structure
    - Script is idempotent: safe to re-run in development

Scope:
    CRM source tables
    ERP source tables
============================================================
*/

------------------------------------------------------------
-- CRM CUSTOMER INFORMATION TABLE
-- Stores raw customer master data from the CRM system
------------------------------------------------------------
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id           INT,           -- Internal customer identifier
    cst_key          NVARCHAR(50),   -- Business/customer reference key
    cst_firstname    NVARCHAR(50),   -- Customer first name
    cst_lastname     NVARCHAR(50),   -- Customer last name
    cst_gndr         NVARCHAR(50),   -- Customer gender (raw source value)
    cst_create_date  DATE            -- Customer record creation date
);

------------------------------------------------------------
-- CRM PRODUCT INFORMATION TABLE
-- Stores raw product master data from the CRM system
------------------------------------------------------------
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id        INT,              -- Internal product identifier
    prd_key       NVARCHAR(50),      -- Business/product reference key
    prd_nm        NVARCHAR(50),      -- Product name
    prd_cost      INT,               -- Product cost (raw value)
    prd_line      NVARCHAR(50),      -- Product line or category
    prd_start_dt  DATETIME,          -- Product validity start date
    prd_end_dt    DATETIME           -- Product validity end date
);

------------------------------------------------------------
-- CRM SALES DETAILS TABLE
-- Stores transactional sales data from the CRM system
------------------------------------------------------------
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num   NVARCHAR(50),      -- Sales order number
    sls_prd_key   NVARCHAR(50),      -- Product reference key
    sls_cust_id   INT,               -- Customer identifier
    sls_order_dt  INT,               -- Order date (raw integer format)
    sls_ship_dt   INT,               -- Shipping date (raw integer format)
    sls_due_dt    INT,               -- Due date (raw integer format)
    sls_sales     INT,               -- Sales amount
    sls_quantity  INT,               -- Quantity sold
    sls_price     INT                -- Unit price
);

------------------------------------------------------------
-- ERP CUSTOMER TABLE (AZ12 SOURCE)
-- Stores raw customer demographic data from ERP system
------------------------------------------------------------
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),             -- Customer identifier
    bdate  DATE,                     -- Birth date
    gen    NVARCHAR(50)              -- Gender (raw ERP value)
);

------------------------------------------------------------
-- ERP CUSTOMER LOCATION TABLE (A101 SOURCE)
-- Stores customer country/location information from ERP
------------------------------------------------------------
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),             -- Customer identifier
    cntry  NVARCHAR(50)              -- Country
);

------------------------------------------------------------
-- ERP PRODUCT CATEGORY TABLE (PX_CAT_G1V2 SOURCE)
-- Stores product category and maintenance attributes
------------------------------------------------------------
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),       -- Product identifier
    cat          NVARCHAR(50),       -- Product category
    subcat       NVARCHAR(50),       -- Product sub-category
    maintenance  NVARCHAR(50)        -- Maintenance classification
);
