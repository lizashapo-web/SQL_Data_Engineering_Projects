-- Step 1: DW - Load data from parquet files into a staging tables

DESCRIBE SELECT *
FROM read_parquet('D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_postings_2025-07.parquet');

DESCRIBE SELECT *
FROM read_parquet('D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_skills.parquet');

SELECT *
FROM read_parquet(
    'D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_postings_2025-07.parquet'
)
LIMIT 5;

SELECT *
FROM read_parquet(
    'D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_skills.parquet'
)
LIMIT 10;

 SELECT 
    error,
    COUNT(*) AS amount
FROM read_parquet(
    'D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_postings_2025-07.parquet'
)
GROUP BY error;

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.job_postings AS
SELECT *
FROM read_parquet(
    'D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_postings_*.parquet'
)
WHERE error IS NULL;

SELECT *
FROM staging.job_postings
LIMIT 10;

CREATE TABLE staging.job_skills AS
SELECT *
FROM read_parquet(
    'D:/dbt_Analytics_Engineering_Course/project_1/data/raw/raw_job_skills.parquet'
);

SELECT COUNT(*)
FROM staging.job_skills;

SELECT *
FROM staging.job_skills
LIMIT 10;

SELECT COUNT(*) AS skills_without_job
FROM staging.job_skills s
LEFT JOIN staging.job_postings p
    ON s.job_id = p.job_id
WHERE p.job_id IS NULL;