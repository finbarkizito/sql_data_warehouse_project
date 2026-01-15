-- =====================================================
-- ERP LOCATION (erp_loc_a101) — CHECK QUERIES (BRONZE ➜ SILVER)
-- Extracted SELECT statements used to validate keys, standardise cntry, and verify final data
-- =====================================================


-- =====================================================
-- CHECK 1: Baseline inspection of raw location table
-- Purpose: Confirm available fields + spot obvious issues before transformations
SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101;


-- =====================================================
-- CHECK 2: Inspect CRM customer keys (reference table)
-- Purpose: Identify the authoritative customer keys to validate cid against
SELECT cst_key
FROM silver.crm_cust_info;


-- =====================================================
-- CHECK 3: Key compatibility (erp cid ➜ crm cst_key) after dash removal
-- Purpose: Ensure cleaned cid exists in CRM (dash formatting breaks joins)
-- Expectation: No rows (rows returned = unmatched customers)
SELECT
    cid,
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);


-- =====================================================
-- CHECK 4: Confirm cleaned cid output (preview)
-- Purpose: Preview final cid format used for insert
-- Expectation: Same key format as silver.crm_cust_info.cst_key
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);


-- =====================================================
-- CHECK 5: Country domain review + mapping validation (initial mapping)
-- Purpose: See all raw cntry values and how CASE mapping standardises them
SELECT DISTINCT
    cntry AS old_cntry,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry = 'NULL' THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


-- =====================================================
-- CHECK 6: Preview cleaned output (cid + mapped cntry)
-- Purpose: Validate transformation result before inserting into silver
SELECT
    cid,
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry = 'NULL' THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;


-- =====================================================
-- CHECK 7: Sort review of mapped countries
-- Purpose: Quick scan for unexpected mapped outputs / noise
SELECT
    cid,
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry = 'NULL' THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


-- =====================================================
-- CHECK 8: Post-load inspection of silver table
-- Purpose: Confirm insert succeeded + columns populated
SELECT *
FROM silver.erp_loc_a101;


-- =====================================================
-- CHECK 9: Country mapping validation (improved null/blank handling)
-- Purpose: Confirm cntry mapping covers NULLs, blanks, and literal 'NULL'
SELECT DISTINCT
    cntry AS old_cntry,
    CASE
        WHEN cntry IS NULL THEN 'N/A'
        WHEN NULLIF(LTRIM(RTRIM(cntry)), '') IS NULL THEN 'N/A'
        WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
        WHEN LTRIM(RTRIM(cntry)) IN ('US', 'USA') THEN 'United States'
        WHEN LTRIM(RTRIM(cntry)) = 'NULL' THEN 'N/A'
        ELSE LTRIM(RTRIM(cntry))
    END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


-- =====================================================
-- CHECK 10: Verify cntry domain in silver after truncate + reinsert
-- Purpose: Confirm null/blank removal worked (domain should be clean)
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- =====================================================
-- CHECK 11: Final inspection of the silver table
-- Purpose: Final scan for sanity before moving on
SELECT *
FROM silver.erp_loc_a101;
