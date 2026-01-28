/*
====================================================================================================================
Stored Procedure: bronze.load_bronze
====================================================================================================================
What this script does:
    - Creates (or alters) a stored procedure called bronze.load_bronze.
    - The procedure performs a full reload of the BRONZE layer by:
        1) Truncating each bronze table (removing all existing rows)
        2) Bulk inserting fresh data from source CSV files (CRM and ERP)
    - Tracks and prints timing information:
        - Per-table load duration
        - Total (batch) bronze-layer load duration
    - Uses TRY/CATCH to capture and print error details if any load step fails.

Why this exists:
    - Bronze loads are typically repeated regularly (e.g., daily) to refresh raw ingested data.
    - The PRINT statements provide lightweight observability for load progress and performance.
====================================================================================================================
*/

-- since we have to run it everyday, we can go and create a stored procedure for running these scripts.
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
    -- Declare timing variables used to measure:
    -- 1) Individual table load duration (@start_time, @end_time)
    -- 2) Total bronze batch duration (@batch_start_time, @batch_end_time)
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    --we had to define a start_time variable to let us know how each table takes to load. 
    -- we also had to define the batch_start_time to determine how long the whole bronze layer will load. 
    BEGIN TRY
        -- Mark the overall start time for the entire bronze-layer batch load
        SET @batch_start_time = GETDATE();

        -- we can also add a dd a print to let us kow that this stored procedure is to load the bronze layer. 
        PRINT '============================';
        PRINT 'lOADING BRONZE lAYER'
        PRINT '============================';


        -- Section header for CRM loads
        PRINT '-------------------------------';
        PRINT 'lOADING CRM TABLES'
        PRINT '-------------------------------';


        -- ============================
        -- CRM: bronze.crm_cust_info
        -- Steps:
        --   1) Start timer
        --   2) TRUNCATE target table (full reload)
        --   3) BULK INSERT from CSV
        --   4) End timer and PRINT duration
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>>Truncating;bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting data into:bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            -- Skip the header row in the CSV
            FIRSTROW = 2,
            -- Comma-separated values
            FIELDTERMINATOR = ',',
            -- Table-level lock to optimize bulk load performance
            TABLOCK
        );
        -- Capture end time for this table load
        SET @end_time = GETDATE()
        -- Print per-table duration in seconds
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';


        -- ============================
        -- CRM: bronze.crm_prd_info
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>>Truncating;bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting data into:crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        -- NOTE: Duration is printed using @end_time; ensure @end_time is set after this load if you want accurate timing.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';


        -- ============================
        -- CRM: bronze.crm_sales_details
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>>Truncating;bronze.crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting data into:crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        -- NOTE: Duration is printed using @end_time; ensure @end_time is set after this load if you want accurate timing.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';


        -- Section header for ERP loads
        PRINT '-------------------------------'
        PRINT 'lOADING ERP TABLES'
        PRINT '-------------------------------'


        -- ============================
        -- ERP: bronze.erp_cust_az12
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>>Truncating;bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting data into:erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        -- NOTE: Duration is printed using @end_time; ensure @end_time is set after this load if you want accurate timing.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';


        -- ============================
        -- ERP: bronze.erp_loc_a101
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>> Truncating:erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting data into:erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        -- NOTE: Duration is printed using @end_time; ensure @end_time is set after this load if you want accurate timing.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';


        -- ============================
        -- ERP: bronze.erp_px_cat_g1v2
        -- ============================
        SET @start_time = GETDATE();
        PRINT '>> Truncating:erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting data into:erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\emman\OneDrive\postgraduate learning\Data with Baraa\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        -- NOTE: Duration is printed using @end_time; ensure @end_time is set after this load if you want accurate timing.
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '>> -------';

        -- Mark end time for the full bronze-layer batch load
        SET @batch_end_time = GETDATE();

        -- Print totalI summary for overall bronze-layer duration
        Print '=============================='
        Print'  - Total load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds'
        Print '=============================='
    END TRY

    -- Error handling block:
    -- If any statement inside TRY fails, control jumps here and prints SQL Server error details.
    BEGIN CATCH
        PRINT '================================================='
        PRINT 'ERROR OCCURRED DURING LOADINF BRONVE LAYER'
        PRINT 'Error message' + ERROR_MESSAGE();
        PRINT 'Error message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '================================================='
        --we now have a script to the bronze layer.
        END CATCH
END

--Now we add tracking ETL duration to help us understand where the issue and bottlenecks are in out data. Also help us to monitor trends. 
