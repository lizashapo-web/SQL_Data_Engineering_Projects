-- Step 1: DW - Load data from parquet files into a staging tables

.read Projects/2_DW_Mart_Build/01_staging.sql

-- Step 2: DW - Load cleaned data into the warehouse
.read Projects/2_DW_Mart_Build/02_create_tables_dw.sql

-- Step 3: Create mart table
.read Projects/2_DW_Mart_Build/03_data_mart.sql

-- Spep 4: Test Mart
.read Projects/2_DW_Mart_Build/tests_mart.sql