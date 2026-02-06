-- =====================================================
-- GOLD LAYER (dim_product build) — CHECK QUERIES
-- Extracted SELECT statements used to validate “current products”, join coverage, and uniqueness.
-- =====================================================


-- =====================================================
-- CHECK 1: Filter to current product records only
-- Purpose: silver.crm_prd_info contains historical + current versions; current rows have prd_end_dt IS NULL
-- Expectation: Result set = current product master list
SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pn.prd_end_dt
FROM silver.crm_prd_info pn
WHERE prd_end_dt IS NULL;


-- =====================================================
-- CHECK 2: Join current products to category reference (coverage check)
-- Purpose: Add category attributes via LEFT JOIN (CRM is master; keep all products even if category missing)
-- Expectation: All products retained; category fields may be NULL if no match
SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;


-- =====================================================
-- CHECK 3: Uniqueness of product_number (prd_key) after join
-- Purpose: Ensure the dim grain is 1 row per prd_key (no duplicates introduced by join or source)
-- Expectation: No rows
SELECT prd_key, COUNT(*)
FROM (
    SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL
) t
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- =====================================================
-- CHECK 4: Same uniqueness check (reordered columns for readability)
-- Purpose: Same validation, cleaner layout for reviewing duplicates if any appear
-- Expectation: No rows
SELECT prd_key, COUNT(*)
FROM (
    SELECT
        pn.prd_id,
        pn.prd_key,
        pn.prd_nm,
        pn.cat_id,
        pc.cat,
        pc.subcat,
        pc.maintenance,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL
) t
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- =====================================================
-- CHECK 5: Final inspection of the gold dimension (post-build)
-- Purpose: Validate the output exists and looks correct
SELECT *
FROM gold.dim_product;
