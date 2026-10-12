-- =========================================================
-- Project: Remote Work Skills Intelligence
-- File: 01_create_tables_dw.sql
-- Purpose: Load data into the Data Warehouse and validate it
-- =========================================================


-- =========================================================
-- STEP 1: CREATE WAREHOUSE SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS warehouse;


-- =========================================================
-- STEP 2: LOAD DATA INTO WAREHOUSE
-- =========================================================

CREATE TABLE IF NOT EXISTS warehouse.job_postings AS
SELECT *
FROM staging.job_postings;


CREATE TABLE IF NOT EXISTS warehouse.job_skills AS
SELECT *
FROM staging.job_skills;


-- =========================================================
-- STEP 3: VALIDATE LOADED ROW COUNTS
-- Compare staging and warehouse
-- =========================================================

SELECT
    'job_postings' AS table_name,
    (SELECT COUNT(*) FROM staging.job_postings) AS staging_rows,
    (SELECT COUNT(*) FROM warehouse.job_postings) AS warehouse_rows

UNION ALL

SELECT
    'job_skills',
    (SELECT COUNT(*) FROM staging.job_skills),
    (SELECT COUNT(*) FROM warehouse.job_skills);


-- =========================================================
-- STEP 4: PROFILE JOB POSTING DATA
-- Check missing IDs and candidate key fields
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE job_id IS NULL
    ) AS null_job_ids,
    COUNT(*) FILTER (
        WHERE company_name IS NULL
    ) AS null_company_names,
    COUNT(*) FILTER (
        WHERE job_title IS NULL
    ) AS null_job_titles,
    COUNT(*) FILTER (
        WHERE job_id IS NOT NULL
          AND (
              company_name IS NULL
              OR job_title IS NULL
          )
    ) AS rows_missing_candidate_key_fields
FROM warehouse.job_postings;


-- =========================================================
-- STEP 5: INVESTIGATE POSTINGS WITHOUT JOB IDs
-- =========================================================

SELECT
    COUNT(*) AS rows_without_job_id,
    COUNT(*) FILTER (
        WHERE job_work_from_home IS TRUE
    ) AS remote_rows,
    COUNT(*) FILTER (
        WHERE job_work_from_home IS NULL
    ) AS unknown_remote_rows,
    COUNT(DISTINCT company_name) AS companies,
    COUNT(DISTINCT job_title) AS job_titles
FROM warehouse.job_postings
WHERE job_id IS NULL;


-- =========================================================
-- STEP 6: PROFILE REMOTE POSTINGS WITHOUT JOB IDs
-- =========================================================

SELECT
    COUNT(DISTINCT company_name) AS companies,
    COUNT(*) AS remote_rows_without_job_id
FROM warehouse.job_postings
WHERE job_id IS NULL
  AND job_work_from_home IS TRUE;