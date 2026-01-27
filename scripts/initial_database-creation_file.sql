/*
=========================================================================
-- Create Database 'DataWarehouse' and Schemas; Gold, Silver and bronze
=========================================================================
### Script Purpose

This script creates a database named `DataWarehouse` after first checking whether it already exists. If the database is present, it is dropped and recreated. The script also sets up three schemas within the database: `bronze`, `silver`, and `gold`.

### ⚠️ Warning

Running this script will permanently delete the existing `DataWarehouse` database and all of its contents. Proceed with caution and ensure that appropriate backups are available before execution.


*/

USE master;
GO

--Drop and recreate the 'DataWarehouse' Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse'
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO
-- Creating the 'DataWarehouse' database

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
