-- =====================================================
-- GOLD.fact_sales — ROOT CAUSE, FIX, AND VERIFICATION
-- Issue: NULL customer joins caused by using business key instead of the surrogate key
-- =====================================================


-- =====================================================
-- STEP 0: ORIGINAL (WRONG) FACT VIEW CREATION
-- Problem: Fact stores sd.sls_cust_id (business key) instead of cu.customer_key (surrogate key)
-- Impact: fact_sales cannot correctly join to dim_customers
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num   AS order_number,
    pr.product_key,
    sd.sls_cust_id,                       -- ❌ WRONG: business/customer id
    sd.sls_order_dt  AS order_date,
    sd.sls_ship_dt   AS shipping_date,
    sd.sls_due_dt    AS due_date,
    sd.sls_sales     AS sales_amount,
    sd.sls_quantity  AS quantity,
    sd.sls_price     AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;


-- =====================================================
-- STEP 1: DETECT THE ISSUE (MODEL JOIN TEST)
-- Purpose: Identify orphan fact rows after building the view
-- Result: Many rows returned → broken customer join
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.sls_cust_id      -- ❌ mismatched key types
WHERE c.customer_key IS NULL;


-- =====================================================
-- STEP 2: DIAGNOSE THE ROOT CAUSE
-- Finding: fact output does not contain the customer surrogate key
-- We must replace sd.sls_cust_id with cu.customer_key
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key,
    sd.sls_cust_id,                        -- business key present
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;


-- =====================================================
-- STEP 3: CORRECTED FACT SELECT (PREVIEW)
-- Fix: Use cu.customer_key and drop the raw customer id
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key,
    cu.customer_key,                       -- ✅ FIXED: surrogate key
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;


-- =====================================================
-- STEP 4: APPLY THE FIX (REPLACE THE VIEW)
-- Purpose: Persist the corrected surrogate-key logic in gold.fact_sales
/*
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO
*/


-- =====================================================
-- STEP 5: VERIFY THE FIX
-- Expectation: Zero orphan rows after correction
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;
