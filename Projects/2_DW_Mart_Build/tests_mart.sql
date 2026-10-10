
-- Test 1: Check MART row count and unique jobs

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_jobs
FROM mart.job_postings_flat;


-- Test 2: Check jobs without skills

SELECT
    COUNT(*) AS jobs_without_skills
FROM mart.job_postings_flat
WHERE skill_keyword IS NULL;


-- Test 3: Check exact duplicate job-skill pairs

SELECT
    COUNT(*) AS total_skill_rows,
    COUNT(DISTINCT (job_id, skill_keyword)) AS unique_job_skills
FROM mart.job_postings_flat
WHERE skill_keyword IS NOT NULL;


-- Test 4: Check jobs without an ID in the warehouse

SELECT
    COUNT(*) AS null_job_ids
FROM warehouse.job_postings
WHERE job_id IS NULL;
