
@echo off
setlocal
cd /d "%~dp0"

duckdb job_market.duckdb -c ".read Projects/2_DW_Mart_Build/build_marts.sql"

if errorlevel 1 (
    echo Pipeline failed.
    exit /b 1
)

echo Pipeline completed successfully.
