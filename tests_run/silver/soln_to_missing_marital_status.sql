
/**********************************************************
TITLE: To fix a Missing Column in the Bronze Layer 
**********************************************************/

----------------------------------------
CONTEXT
----------------------------------------
- While developing the silver layer, a missing column (cst_marital_status) was identified
  in the bronze table bronze.crm_cust_info.
- The objective was to correct the bronze schema without dropping or recreating the table,
  so that existing silver-layer work would not be disrupted.

----------------------------------------
PROBLEM
----------------------------------------
- Silver queries referenced cst_marital_status and failed because the column did not exist.
- Adding the column via ALTER TABLE resulted in NULL values because existing rows were
  loaded before the column existed.

----------------------------------------
SOLUTION APPROACH
----------------------------------------
Option A: ALTER TABLE + Reload/Populate
- Add the missing column safely.
- Reload or populate data so the new column contains values.
- Avoid dropping the bronze table during active silver development.

----------------------------------------
STEP-BY-STEP RESOLUTION
----------------------------------------

----------------------------------------
STEP 0 – CONFIRM DATABASE CONTEXT
----------------------------------------
- Ensure the query window is connected to the correct database (not master).

Optional explicit command:
USE DataWarehouseAnalytics;
GO

----------------------------------------
STEP 1 – ADD THE MISSING COLUMN
----------------------------------------
- Add the column without dropping the existing table.

ALTER TABLE bronze.crm_cust_info
ADD cst_marital_status NVARCHAR(50);

Expected result:
- Command completes successfully.
- Column exists but contains NULL values for existing rows.

----------------------------------------
STEP 2 – VERIFY COLUMN EXISTENCE
----------------------------------------
- Confirm the column is now part of the table schema.

SELECT TOP (5) *
FROM bronze.crm_cust_info;

Expected result:
- cst_marital_status appears in the result set.

----------------------------------------
STEP 3 – POPULATE THE NEW COLUMN BY TRUNCATE AND RELOAD
----------------------------------------
Note:
- BULK INSERT loads data by column position, not by column name.
- The table column order must match the CSV header order.

3A-1) Clear the table (bronze is designed to be reloadable):
TRUNCATE TABLE bronze.crm_cust_info;

3A-2) Reload data from the source CSV:
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

----------------------------------------
STEP 4 – VALIDATE DATA POPULATION
----------------------------------------
- Check whether the new column contains values.

SELECT
    cst_marital_status,
    COUNT(*) AS cnt
FROM bronze.crm_cust_info
GROUP BY cst_marital_status
ORDER BY cnt DESC;

Expected result:
- Non-NULL marital status values appear with meaningful counts.

----------------------------------------
STEP 5 – UPDATE SILVER TRANSFORMATIONS
----------------------------------------
- Include the new column in silver-layer queries.
- Apply trimming and standardisation as needed.

Example:
TRIM(cst_marital_status) AS cst_marital_status

----------------------------------------
OUTCOME
----------------------------------------
- Bronze schema corrected without dropping the table.
- New column successfully populated.
- Silver development continued without disruption.

****************************************************************************************/
```
