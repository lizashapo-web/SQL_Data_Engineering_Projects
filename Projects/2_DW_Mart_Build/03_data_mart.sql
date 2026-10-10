
-- Step 3: Build the job postings mart

CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE TABLE mart.job_postings_flat AS

WITH ranked_jobs AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY job_id
            ORDER BY search_time DESC
        ) AS rn
    FROM warehouse.job_postings
    WHERE job_id IS NOT NULL
),

latest_jobs AS (
    SELECT *
    FROM ranked_jobs
    WHERE rn = 1
)

SELECT
    p.job_id,
    p.job_title,
    p.company_name,
    p.job_location,
    p.job_via,
    p.job_posted_at,
    p.job_salary,
    p.job_schedule_type,
    p.job_work_from_home,
    p.search_time,
    p.search_date,
    p.search_term,
    p.search_location,
    s.skill_id,
    s.skill_keyword
FROM latest_jobs AS p
LEFT JOIN warehouse.job_skills AS s
    ON p.job_id = s.job_id;

