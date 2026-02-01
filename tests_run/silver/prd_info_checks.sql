-- =====================================================
-- CHECK 1: To inspect raw product table structure
-- Purpose: Baseline inspection of available columns and values
-- Expectation: Understand raw bronze-level data before transformation
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


-- =====================================================
-- CHECK 2: Validate category ID extraction logic
-- Purpose: Confirm that the first 5 characters of prd_key form a valid category ID
-- Expectation: Extracted category IDs should align with category reference table
SELECT
    prd_id,
    prd_key,
    SUBSTRING(prd_key, 1, 5) AS cat_id
FROM bronze.crm_prd_info;


-- =====================================================
-- CHECK 3: Inspect valid category IDs in category reference table
-- Purpose: Identify the authoritative list of category IDs
-- Expectation: These IDs will be used to validate extracted category values
SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;


-- =====================================================
-- CHECK 4: Identify category mismatches caused by formatting differences
-- Purpose: Detect category IDs that do not match due to '-' vs '_' formatting
-- Expectation: Rows returned indicate formatting inconsistencies
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (
    SELECT DISTINCT id
    FROM bronze.erp_px_cat_g1v2
);


-- =====================================================
-- CHECK 5: Extract and inspect product number portion of prd_key
-- Purpose: Separate product number for joining to sales data
-- Expectation: Extracted values should exist in sales details table
SELECT
    prd_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info;


-- =====================================================
-- CHECK 6: Inspect valid product keys in sales details table
-- Purpose: Identify which product keys are actually referenced by sales
-- Expectation: Used as a filter to remove orphan products
SELECT
    sls_prd_key
FROM bronze.crm_sales_details;


-- =====================================================
-- CHECK 7: Identify products not referenced in sales data
-- Purpose: Detect orphan product records
-- Expectation: Returned rows represent products excluded from silver layer
SELECT
    prd_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (
    SELECT sls_prd_key
    FROM bronze.crm_sales_details
);


-- =====================================================
-- CHECK 8: Validate filtered product list used for silver layer
-- Purpose: Confirm only products with sales references remain
-- Expectation: Result set defines final product population
SELECT
    prd_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (
    SELECT sls_prd_key
    FROM bronze.crm_sales_details
);


-- =====================================================
-- CHECK 9: Identify NULL product costs
-- Purpose: Detect missing numeric values prior to defaulting to 0
-- Expectation: NULLs exist and must be handled explicitly
SELECT
    prd_id,
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL;


-- =====================================================
-- CHECK 10: Inspect raw product line codes
-- Purpose: Identify abbreviations requiring standardisation
-- Expectation: Values limited to M, R, S, T (plus potential noise)
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;


-- =====================================================
-- CHECK 11: Validate product date sequencing
-- Purpose: Identify overlapping or incorrect date ranges
-- Expectation: End date should always be >= start date
SELECT
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');


-- =====================================================
-- CHECK 12: Confirm derived end-date logic across all products
-- Purpose: Ensure LEAD-based end-date derivation works globally
-- Expectation: Derived end dates resolve date overlaps correctly
SELECT
    prd_id,
    prd_key,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - 1 AS DATE
    ) AS prd_end_dt_test
FROM bronze.crm_prd_info;
