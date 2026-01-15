-- =====================================================
-- SCRIPT A — SILVER DATA-QUALITY CHECKS (erp_cust_az12)
-- Extracted SELECT statements used to validate silver.erp_cust_az12
-- =====================================================

-- CHECK A1: Birthdate range validity
-- Purpose: Identify impossible birthdates (too old / future dates)
-- Expectation: No rows
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- CHECK A2: Gender domain review
-- Purpose: See all distinct gender values after standardisation
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- CHECK A3: Final inspection of the silver table
-- Purpose: Quick scan to confirm load + column population
SELECT *
FROM silver.erp_cust_az12;



-- =====================================================
-- SCRIPT B — BRONZE ➜ SILVER TRANSFORMATION + CHECKS (erp_cust_az12)
-- Extracted SELECT statements used to validate joins, clean fields, and standardise values
-- =====================================================

-- CHECK B1: Targeted record inspection (specific customer)
-- Purpose: Manually verify how cid/bdate/gen look for a known example
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';


-- CHECK B2: Inspect CRM customer dimension (reference table)
-- Purpose: Ensure the join target exists and keys are available
SELECT *
FROM silver.crm_cust_info;


-- CHECK B3: Customer key compatibility (erp cid ➜ crm cst_key)
-- Purpose: Validate cid cleaning rule ("NAS" prefix removal) produces keys present in CRM
-- Expectation: No rows (your comment says none)
SELECT
    cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
      END NOT IN (
          SELECT DISTINCT cst_key
          FROM silver.crm_cust_info
      );


-- CHECK B4: Confirm cleaned cid output (preview)
-- Purpose: Preview final cid shape before insert
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;


-- CHECK B5: Birthdate outliers in bronze
-- Purpose: Find impossible birthdates before nulling/fixing
-- Expectation: Rows returned = bad dates
SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- CHECK B6: Preview birthdate cleaning rule
-- Purpose: Validate future dates become NULL (keeps plausible historical values)
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    bdate,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    gen
FROM bronze.erp_cust_az12;


-- CHECK B7: Gender value mapping review
-- Purpose: Check all raw gender values + how the CASE mapping standardises them
SELECT DISTINCT
    gen,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('F', 'MALE') THEN 'Male'
        ELSE 'N/A'
    END AS gen
FROM bronze.erp_cust_az12;


-- CHECK B8: Final transformed output preview (cid + bdate + gen)
-- Purpose: Confirm the full transformation result before insert
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('F', 'MALE') THEN 'Male'
        ELSE 'N/A'
    END AS gen
FROM bronze.erp_cust_az12;
