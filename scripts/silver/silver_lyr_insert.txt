/*==============================================================================
SILVER LAYER – MASTER LOAD SCRIPT (SHORTCUT)
------------------------------------------------------------------------------
Purpose:
    This script truncates and repopulates all SILVER-layer tables from BRONZE
    using transformation logic (standardisation, trimming, datatype conversion,
    and basic validation rules).

Notes:
    - This is designed to be re-run (reload-style ETL).
    - Each section prints what is being truncated/loaded for traceability.
==============================================================================*/

PRINT '============================================================';
PRINT 'START: LOADING SILVER LAYER';
PRINT '============================================================';
PRINT ' ';

-- ---------------------------------------------------------------------------
-- CRM: CUSTOMER INFORMATION
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: CRM CUSTOMER INFORMATION (silver.crm_cust_info)';
PRINT '------------------------------------------------------------';

-- Truncating the silver customer information table.
PRINT '>> Truncating: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT '>> Truncate complete: silver.crm_cust_info';

PRINT '>> Inserting data into: silver.crm_cust_info';
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    LTRIM(RTRIM(cst_firstname)) AS cst_firstname,
    LTRIM(RTRIM(cst_lastname))  AS cst_lastname,
    CASE
        WHEN UPPER(LTRIM(RTRIM(cst_marital_status))) = 'S' THEN 'Single'
        WHEN UPPER(LTRIM(RTRIM(cst_marital_status))) = 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(LTRIM(RTRIM(cst_gndr))) = 'F' THEN 'FEMALE'
        WHEN UPPER(LTRIM(RTRIM(cst_gndr))) = 'M' THEN 'MALE'
        ELSE 'N/A'
    END AS cst_gndr,
    TRY_CONVERT(DATE, cst_create_date) AS cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY TRY_CONVERT(DATE, cst_create_date) DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;
PRINT '>> Insert complete: silver.crm_cust_info';
PRINT ' ';


-- ---------------------------------------------------------------------------
-- CRM: PRODUCT INFORMATION
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: CRM PRODUCT INFORMATION (silver.crm_prd_info)';
PRINT '------------------------------------------------------------';

PRINT '>> Inserting data into: silver.crm_prd_info';
INSERT INTO silver.crm_prd_info (
	prd_id,			
	cat_id,		
	prd_key,			
	prd_nm,		
	prd_cost,		
	prd_line,		
	prd_start_dt,	
	prd_end_dt	
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5), '-', '_') AS cat_id,
	SUBSTRING(prd_key,7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE WHEN UPPER(TRIM (prd_line)) = 'M' THEN 'Mountain'
		 WHEN UPPER(TRIM (prd_line)) = 'R' THEN 'Road'
		 WHEN UPPER(TRIM (prd_line)) = 'S' THEN 'other sales'
		 WHEN UPPER(TRIM (prd_line)) = 'T' THEN 'Touring'
		 else 'N/A'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt_test
	FROM bronze.crm_prd_info;
PRINT '>> Insert complete: silver.crm_prd_info';
PRINT ' ';


-- ---------------------------------------------------------------------------
-- CRM: SALES DETAILS
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: CRM SALES DETAILS (silver.crm_sales_details)';
PRINT '------------------------------------------------------------';

PRINT '>> Inserting data into: silver.crm_sales_details';
-- now we insert the sales details table.
INSERT INTO silver.crm_sales_details (
    sls_ord_num, sls_prd_key, sls_cust_id,
    sls_order_dt, sls_ship_dt, sls_due_dt,
    sls_sales, sls_quantity, sls_price
)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) as DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) as DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) as DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales is NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity*ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price is NULL OR sls_price <=0 
			THEN sls_sales/NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details;
PRINT '>> Insert complete: silver.crm_sales_details';
PRINT ' ';


-- ---------------------------------------------------------------------------
-- ERP: CUSTOMER (AZ12)
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: ERP CUSTOMER (AZ12) (silver.erp_cust_az12)';
PRINT '------------------------------------------------------------';

PRINT '>> Inserting data into: silver.erp_cust_az12';
-- Now inserting the erp.cust_az12 table 
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING (cid, 4, LEN(cid))
	 ELSE cid
END cid,
CASE WHEN bdate > GETDATE () THEN NULL
	 ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('F', 'MALE') THEN 'Male'
	ELSE 'N/A'
END AS gen
FROM bronze.erp_cust_az12;
PRINT '>> Insert complete: silver.erp_cust_az12';
PRINT ' ';


-- ---------------------------------------------------------------------------
-- ERP: PRODUCT CATEGORY (PX_CAT_G1V2)
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: ERP PRODUCT CATEGORY (silver.erp_px_cat_g1v2)';
PRINT '------------------------------------------------------------';

PRINT '>> Inserting data into: silver.erp_px_cat_g1v2';
--- now inserting the erp_px_cat_g1v2
INSERT INTO silver.erp_px_cat_g1v2
(id, cat, subcat, maintenance)
SELECT
id,
cat,
subcat, 
maintenance
FROM bronze.erp_px_cat_g1v2;
PRINT '>> Insert complete: silver.erp_px_cat_g1v2';
PRINT ' ';


-- ---------------------------------------------------------------------------
-- ERP: LOCATION (A101)
-- ---------------------------------------------------------------------------
PRINT '------------------------------------------------------------';
PRINT 'SECTION: ERP LOCATION (A101) (silver.erp_loc_a101)';
PRINT '------------------------------------------------------------';

--- now inserting the erp_loc_a101
PRINT '>> Truncating: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
PRINT '>> Truncate complete: silver.erp_loc_a101';

PRINT '>> Inserting data into: silver.erp_loc_a101';
-- then we reinsert the table back
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN cntry IS NULL THEN 'N/A'
        WHEN NULLIF(LTRIM(RTRIM(cntry)), '') IS NULL THEN 'N/A'
        WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
        WHEN LTRIM(RTRIM(cntry)) IN ('US', 'USA') THEN 'United States'
        WHEN LTRIM(RTRIM(cntry)) = 'NULL' THEN 'N/A'
        ELSE LTRIM(RTRIM(cntry))
    END AS cntry
FROM bronze.erp_loc_a101;
PRINT '>> Insert complete: silver.erp_loc_a101';
PRINT ' ';


PRINT '============================================================';
PRINT 'END: LOADING SILVER LAYER';
PRINT '============================================================';
