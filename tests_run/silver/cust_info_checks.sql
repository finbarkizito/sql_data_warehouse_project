/*============================================================
 Check 1: Primary Key Integrity
 Expectation: No rows returned
 -  There should be no NULL primary keys as well as duplicate primary keys
============================================================*/

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/*============================================================
 Check 2: Unwanted Spaces in Business Key
 Expectation: No rows returned
 - Detect leading or trailing spaces in cst_key
============================================================*/

SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != LTRIM(RTRIM(cst_key));


/*============================================================
 Check 3: Data Standardisation & Consistency
 Purpose:
 - Inspect distinct marital status values
 - Identify inconsistent encodings (e.g. S/M, Single/Married)
============================================================*/

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


============================================================*/

-- row count
SELECT COUNT(*) AS row_count
FROM silver.crm_cust_info;

============================================================*/
-- checking our columns 
SELECT TOP (20)
    cst_id,
    cst_key,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM silver.crm_cust_info
ORDER BY cst_id;

============================================================*/
--confirming Marital status distribution. 
SELECT
    cst_marital_status,
    COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_marital_status
ORDER BY cnt DESC;

============================================================*/

-- Data standardization and conssitency. 
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info
