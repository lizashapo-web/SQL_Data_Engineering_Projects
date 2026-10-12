-- =========================================================
-- Project: Remote Work Skills Intelligence
-- File: 03_mart_table.sql
-- Purpose: Build the remote job skills mart
-- Grain: one candidate job x one skill
-- =========================================================


-- =========================================================
-- STEP 1: CREATE MART SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS mart;


-- =========================================================
-- STEP 2: BUILD REMOTE JOB SKILLS MART
-- =========================================================

CREATE OR REPLACE TABLE mart.job_postings_flat AS

WITH ambiguous_job_ids AS (

    -- Identify IDs associated with multiple companies
    -- or multiple job titles.

    SELECT
        job_id
    FROM warehouse.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id
    HAVING
        COUNT(DISTINCT company_name) > 1
        OR COUNT(DISTINCT job_title) > 1
),

eligible_candidates AS (

    -- Keep candidates with confirmed remote evidence.
    -- Exclude ambiguous IDs to avoid incorrect skill attribution.

    SELECT
        c.*
    FROM warehouse.job_candidates c
    WHERE c.job_id IS NOT NULL
      AND c.remote_observation_count > 0
      AND NOT EXISTS (
          SELECT 1
          FROM ambiguous_job_ids a
          WHERE a.job_id = c.job_id
      )
),

ranked_observations AS (

    -- Rank observations within each candidate job.
    -- Keep the most recent observation for descriptive fields.

    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                o.job_id,
                o.company_name,
                o.job_title
            ORDER BY
                o.search_time DESC NULLS LAST,
                o.search_date DESC NULLS LAST,
                o.observation_id DESC
        ) AS rn
    FROM warehouse.job_observations o
    WHERE o.job_id IS NOT NULL
),

latest_observations AS (

    SELECT *
    FROM ranked_observations
    WHERE rn = 1
),

distinct_skills AS (

    -- Remove exact duplicate skill records, if any.

    SELECT DISTINCT
        job_id,
        skill_id,
        skill_keyword
    FROM warehouse.job_skills
)

SELECT
    c.job_id,
    c.company_name,
    c.job_title,

    p.job_location,
    p.job_via,
    p.job_posted_at,
    p.job_salary,
    p.job_schedule_type,

    -- This mart contains candidates with remote evidence.
    TRUE AS has_remote_evidence,

    -- Preserve the status from the selected observation.
    p.job_work_from_home AS latest_observed_remote_status,

    p.search_time,
    p.search_date,
    p.search_term,
    p.search_location,

    c.observation_count,
    c.first_seen_date,
    c.last_seen_date,
    c.remote_observation_count,

    s.skill_id,
    s.skill_keyword

FROM eligible_candidates c

LEFT JOIN latest_observations p
    ON c.job_id = p.job_id
   AND c.company_name = p.company_name
   AND c.job_title = p.job_title

LEFT JOIN distinct_skills s
    ON c.job_id = s.job_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids,

    COUNT(*) FILTER (
        WHERE skill_keyword IS NULL
    ) AS rows_without_skills,

    COUNT(DISTINCT job_id) FILTER (
        WHERE skill_keyword IS NULL
    ) AS jobs_without_skills,

    COUNT(*) FILTER (
        WHERE has_remote_evidence IS NOT TRUE
    ) AS rows_without_remote_evidence
FROM mart.job_postings_flat;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (job_id, skill_keyword))
        FILTER (WHERE skill_keyword IS NOT NULL)
        AS unique_job_skill_pairs
FROM mart.job_postings_flat;