-- =====================================================
-- GOLD.dim_customers — CHECK QUERIES
-- Extracted SELECT statements that were used to validate joins, grain, integration logic, and final output
-- =====================================================


-- =====================================================
-- CHECK 1: Join grain / duplicate detection after LEFT JOINs
-- Purpose: Ensure customer grain stays 1 row per cst_id (no duplicates introduced)
-- Expectation: No rows
SELECT cst_id, COUNT(*)
FROM (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_gndr,
        ci.cst_create_date,
        ci.dwh_create_date,
        ci.cst_marital_status,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- =====================================================
-- CHECK 2: Gender integration review (CRM vs ERP)
-- Purpose: Compared gender fields across sources to understand mismatches / NULL-like content
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- =====================================================
-- CHECK 3: Validate “master source” rule for gender (derived column)
-- Purpose: Confirm new_gen logic: prefer CRM unless CRM is 'N/A', else take ERP (default 'n/a')
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- =====================================================
-- CHECK 4: Post-build domain check on gold dimension
-- Purpose: Confirm final gender values in gold.dim_customers look correct after view creation.
SELECT DISTINCT
    gender
FROM gold.dim_customers;
