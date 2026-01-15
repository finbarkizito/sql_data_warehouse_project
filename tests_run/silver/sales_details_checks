-- =====================================================
-- CRM SALES DETAILS — CHECK QUERIES (BRONZE ➜ SILVER)
-- Extracted SELECT statements that were used to validate / clean data
-- =====================================================


-- =====================================================
-- CHECK 1: Baseline inspection of the raw sales table
-- Purpose: Confirm available fields + spot obvious anomalies before transformations
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- =====================================================
-- CHECK 2: Unwanted spaces in order number
-- Purpose: Detect dirty keys (break joins / duplicates)
-- Expectation: No rows
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- =====================================================
-- CHECK 3: Product key referential integrity (sales ➜ product dimension)
-- Purpose: Ensure every sales product key exists in silver.crm_prd_info
-- Expectation: No rows
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);


-- =====================================================
-- CHECK 4: Customer ID referential integrity (sales ➜ customer dimension)
-- Purpose: Ensure every sales customer ID exists in silver.crm_cust_info
-- Expectation: No rows
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);


-- =====================================================
-- CHECK 5: Invalid order dates (zeros / non-date integers)
-- Purpose: Find placeholder/bad date values before casting
-- Expectation: Ideally no rows, but zeros were present
SELECT 
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;


-- =====================================================
-- CHECK 6: Bad order dates (range + length validation)
-- Purpose: Identify impossible dates + malformed date integers (not 8 chars)
-- Expectation: Rows returned = bad dates to be nulled
SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;


-- =====================================================
-- CHECK 7: Validate final order-date casting logic
-- Purpose: Confirm CASE + CAST logic produces DATE or NULL safely
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_ordr_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- =====================================================
-- CHECK 8: Bad ship dates (range + length validation)
-- Purpose: Same validation rules as order date
-- Expectation: Rows returned = bad dates to be nulled
SELECT 
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


-- =====================================================
-- CHECK 9: Ship date casting logic applied
-- Purpose: Ensure ship date gets same nulling + casting protections
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_ordr_dt,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- =====================================================
-- CHECK 10: Bad due dates (range + length validation)
-- Purpose: Same validation rules as order/ship date
-- Expectation: Rows returned = bad dates to be nulled
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- =====================================================
-- CHECK 11: Full date casting applied (order/ship/due)
-- Purpose: Confirm all date fields are safely transformed to DATE
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- =====================================================
-- CHECK 12: Date sequencing sanity (order before ship/due)
-- Purpose: Detect impossible timelines
-- Expectation: No rows (your comment says none)
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- =====================================================
-- CHECK 13: Sales consistency (sales = qty * price) + null/zero/negative checks
-- Purpose: Identify incorrect revenue math + invalid measures
-- Expectation: Rows returned = bad numeric data
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price = 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- =====================================================
-- CHECK 14: Verify correction logic for sales/price
-- Purpose: Confirm CASE rules generate corrected sales + corrected price
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price = 0;


-- =====================================================
-- SILVER-LAYER CHECKS (post-load) — only added if missing above
-- =====================================================

-- CHECK 15: Invalid date orders (post-transform)
-- Purpose: Ensure DATE fields still respect timeline rules after casting
-- Expectation: No rows
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- CHECK 16: Data consistency (post-transform)
-- Purpose: Confirm corrected metrics satisfy sales = qty * price and are valid
-- Expectation: No rows
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- CHECK 17: Final inspection of the silver table
-- Purpose: Quick scan to confirm load completed + columns populated
SELECT *
FROM silver.crm_sales_details;
