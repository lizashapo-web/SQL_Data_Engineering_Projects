-- Step 2: DW - Load cleaned data into the warehouse

CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.job_postings AS
SELECT *
FROM staging.job_postings;

CREATE TABLE warehouse.job_skills AS
SELECT *
FROM staging.job_skills;

SELECT COUNT(*) FROM warehouse.job_postings;

SELECT COUNT(*) FROM warehouse.job_skills;