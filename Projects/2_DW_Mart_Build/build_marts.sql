-- Step 1: DW - Load data from parquet files into a staging tables

.read 01_staging.sql;

-- Step 2: DW - Load cleaned data into the warehouse
.read 02_create_tables_dw.sql;