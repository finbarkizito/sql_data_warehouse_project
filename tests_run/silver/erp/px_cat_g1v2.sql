-- =====================================================
-- ERP PRODUCT CATEGORY (erp_px_cat_g1v2) — CHECK QUERIES (BRONZE ➜ SILVER)
-- Extracted SELECT statements used to validate cleanliness + value domains + final load
-- =====================================================


-- =====================================================
-- CHECK 1: Baseline inspection of raw category table
-- Purpose: Confirm fields + review raw values before loading to silver
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- =====================================================
-- CHECK 2: Unwanted spaces in string columns
-- Purpose: Detect dirty text fields that break grouping/joins/reporting
-- Expectation: No rows (your comment says none)
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


-- =====================================================
-- CHECK 3: Domain review — maintenance
-- Purpose: Identify all possible values for standardisation / mapping needs
SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- =====================================================
-- CHECK 4: Domain review — cat
-- Purpose: Identify all possible category values
SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2;


-- =====================================================
-- CHECK 5: Domain review — subcat
-- Purpose: Identify all possible subcategory values
SELECT DISTINCT
    subcat
FROM bronze.erp_px_cat_g1v2;


-- =====================================================
-- CHECK 6: Post-load inspection of silver table
-- Purpose: Confirm insert succeeded + data is present
SELECT *
FROM silver.erp_px_cat_g1v2;
