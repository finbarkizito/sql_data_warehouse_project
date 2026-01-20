## Quality checks. 

-- =====================================================================================
-- SILVER LAYER DATA QUALITY CHECKS
-- =====================================================================================
-- Purpose:
--     During the creation of the silver layer, I applied a structured sequence of
--     data quality checks to transform raw bronze data into a clean, standardized,
--     and analytics-ready format. These checks were executed iteratively to both
--     identify issues in the bronze layer and validate that cleansing logic
--     resolved them correctly.
-- =====================================================================================

-- 1. Primary Key Integrity
--    I validated that primary keys contained no NULL values and no duplicates.
--    Where duplicate records were identified, I used ranking functions
--    (e.g. ROW_NUMBER) to retain only the most recent record based on a timestamp.

-- 2. Unwanted Spaces in String Columns
--    I checked text-based columns for leading and trailing spaces by comparing
--    raw values to their trimmed equivalents, ensuring consistent formatting.

-- 3. Data Consistency and Standardization
--    I reviewed low-cardinality attributes (e.g. gender, marital status) for
--    inconsistent representations such as abbreviations versus full values.
--    All values were mapped to a single, standardized, user-friendly format.

-- 4. Data Type and Range Validation
--    I validated numeric fields (e.g. cost, price, quantities) to ensure values
--    were positive and within reasonable ranges.
--    Date fields were checked for logical validity, such as:
--        - Birth dates not occurring in the future
--        - Order dates preceding shipping and due dates

-- 5. Business Logic and Calculations
--    I verified internal record consistency by checking derived fields, ensuring
--    calculations such as sales amount equaling quantity multiplied by unit price.

-- 6. Referential and Integrity Checks
--    I performed lookup validations to confirm that foreign keys (e.g. customer
--    and product keys) existed in their corresponding reference tables, preventing
--    orphaned or unmatched records.

-- 7. Schema and Metadata Validation
--    I confirmed that data was populated into the correct target columns and that
--    newly introduced metadata fields (e.g. dw_create_date) were populated correctly
