/****************************************************************************************
TITLE: Safely Converting a NVARCHAR Date Column to a DATE Data Type

CONTEXT
- The bronze table contains a date column stored as NVARCHAR due to source format issues
  (e.g. DD/MM/YYYY).
- Directly altering the column to DATE can fail if any value is invalid.
- The safe approach is to create a new DATE column, populate it carefully, validate,
  then optionally replace the old column.

GOAL
- Convert cst_create_date from NVARCHAR to a proper DATE data type
- Avoid data loss and avoid breaking the pipeline
****************************************************************************************/


/*------------------------------------------------------------------------------
STEP 1 – ADD A NEW DATE COLUMN (DO NOT REMOVE THE ORIGINAL YET)
------------------------------------------------------------------------------*/
ALTER TABLE bronze.crm_cust_info
ADD cst_create_date_dt DATE;

-- Result:
-- - Raw column (cst_create_date) remains untouched
-- - New column (cst_create_date_dt) will hold the converted DATE values


/*------------------------------------------------------------------------------
STEP 2 – POPULATE THE NEW DATE COLUMN SAFELY
------------------------------------------------------------------------------*/
UPDATE bronze.crm_cust_info
SET cst_create_date_dt =
    TRY_CONVERT(DATE, cst_create_date, 103);

-- Notes:
-- - 103 = British/French date format (DD/MM/YYYY)
-- - TRY_CONVERT prevents the update from failing
-- - Invalid dates are set to NULL instead of crashing


/*------------------------------------------------------------------------------
STEP 3 – VALIDATE THE CONVERSION
------------------------------------------------------------------------------*/
SELECT
    cst_create_date,
    cst_create_date_dt
FROM bronze.crm_cust_info
WHERE cst_create_date_dt IS NULL
  AND cst_create_date IS NOT NULL;

-- Interpretation:
-- - If this returns 0 rows → conversion successful
-- - If rows appear → those source values need investigation


/*------------------------------------------------------------------------------
STEP 4 – USE THE DATE COLUMN GOING FORWARD
------------------------------------------------------------------------------*/
-- In silver-layer transformations, always reference:
--     cst_create_date_dt
-- instead of the NVARCHAR column

-- Example:
-- SELECT
--     cst_id,
--     cst_key,
--     cst_create_date_dt
-- FROM bronze.crm_cust_info;


/*------------------------------------------------------------------------------
STEP 5 – REPLACE THE OLD COLUMN
------------------------------------------------------------------------------*/
-- Only perform this step once you are confident the conversion is correct

-- Drop the raw NVARCHAR column
ALTER TABLE bronze.crm_cust_info
DROP COLUMN cst_create_date;

-- Rename the DATE column to the original column name
EXEC sp_rename
    'bronze.crm_cust_info.cst_create_date_dt',
    'cst_create_date',
    'COLUMN';

-- Final result:
-- - cst_create_date now exists as a proper DATE column
-- - Raw string version has been fully retired


/****************************************************************************************
KEY LESSONS
- Never force a datatype change on unvalidated data
- Always convert into a new column first
- Validate before dropping or renaming columns
- Use TRY_CONVERT to protect pipelines from bad source data
****************************************************************************************/
