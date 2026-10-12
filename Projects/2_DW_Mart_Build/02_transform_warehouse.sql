-- =========================================================
-- Project: Remote Work Skills Intelligence
-- File: 02_transform_warehouse.sql
-- Purpose: Prepare warehouse data for analytics
-- =========================================================


-- =========================================================
-- STEP 1: CREATE JOB OBSERVATIONS TABLE
-- One row represents one source observation
-- =========================================================

CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.job_observations AS
SELECT
    ROW_NUMBER() OVER () AS observation_id,
    *
FROM warehouse.job_postings;


-- =========================================================
-- STEP 2: VALIDATE ROW COUNTS
-- =========================================================

SELECT
    (SELECT COUNT(*)
     FROM warehouse.job_postings) AS source_rows,

    (SELECT COUNT(*)
     FROM warehouse.job_observations) AS observation_rows,

    (SELECT COUNT(DISTINCT observation_id)
     FROM warehouse.job_observations) AS unique_observation_ids;

-- =========================================================
-- STEP 2: CREATE CANDIDATE JOBS TABLE
-- Grain: one row per job_id + company_name + job_title
-- =========================================================

CREATE TABLE IF NOT EXISTS warehouse.job_candidates AS
SELECT
    job_id,
    company_name,
    job_title,

    COUNT(*) AS observation_count,

    MIN(search_date) AS first_seen_date,
    MAX(search_date) AS last_seen_date,

    COUNT(*) FILTER (
        WHERE job_work_from_home IS TRUE
    ) AS remote_observation_count,

    COUNT(DISTINCT search_term) AS search_terms_count,
    COUNT(DISTINCT job_via) AS sources_count

FROM warehouse.job_observations
WHERE job_id IS NOT NULL

GROUP BY
    job_id,
    company_name,
    job_title;


-- =========================================================
-- STEP 3: VALIDATE CANDIDATE JOBS
-- =========================================================

SELECT
    COUNT(*) AS candidate_jobs,
    COUNT(DISTINCT job_id) AS distinct_job_ids,

    COUNT(*) FILTER (
        WHERE remote_observation_count > 0
    ) AS candidates_with_remote_evidence,

    SUM(observation_count) AS total_observations

FROM warehouse.job_candidates;

SELECT
    job_id,
    company_name,
    job_title,
    observation_count,
    remote_observation_count
FROM warehouse.job_candidates
WHERE job_id = '665c811b7d85e8571e2949b0225ee336'
ORDER BY company_name, job_title;

SELECT
    COUNT(*) AS candidate_jobs,
    COUNT(*) FILTER (
        WHERE s.job_id IS NOT NULL
    ) AS candidates_with_skills,
    COUNT(*) FILTER (
        WHERE s.job_id IS NULL
    ) AS candidates_without_skills
FROM warehouse.job_candidates c
LEFT JOIN (
    SELECT DISTINCT job_id
    FROM warehouse.job_skills
) s
    ON c.job_id = s.job_id
WHERE c.remote_observation_count > 0;