-- 00_data_audit.sql
-- Project: Remote Work Skills Intelligence
-- Purpose: Initial exploration and data quality audit
-- Period: July 2025 - June 2026
--
-- Sections:
-- 1. Source data inspection
-- 2. Staging table creation
-- 3. Data quality checks
-- 4. Remote work analysis
-- 5. Job ID and candidate key investigation

-- Staging

DESCRIBE SELECT *
FROM read_parquet('data/raw/raw_job_postings_2025-07.parquet');

DESCRIBE SELECT *
FROM read_parquet('data/raw/raw_job_skills.parquet');

SELECT *
FROM read_parquet(
    'data/raw/raw_job_postings_2025-07.parquet'
)
LIMIT 5;

SELECT *
FROM read_parquet(
    'data/raw/raw_job_skills.parquet'
)
LIMIT 10;

 SELECT 
    error,
    COUNT(*) AS amount
FROM read_parquet(
    'data/raw/raw_job_postings_2025-07.parquet'
)
GROUP BY error;

-- Initial staging setup.
-- Note: IF NOT EXISTS does not refresh existing tables.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.job_postings AS
SELECT *
FROM read_parquet(
    'data/raw/raw_job_postings_*.parquet'
)
WHERE error IS NULL;

SELECT *
FROM staging.job_postings
LIMIT 10;

CREATE TABLE IF NOT EXISTS staging.job_skills AS
SELECT *
FROM read_parquet(
    'data/raw/raw_job_skills.parquet'
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

-- Data Quality

DESCRIBE staging.job_postings;

DESCRIBE staging.job_skills;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids,
    COUNT(*) FILTER (
        WHERE job_id IS NULL
    ) AS null_job_ids,
    COUNT(*) FILTER (
        WHERE job_work_from_home IS TRUE
    ) AS remote_rows,
    COUNT(*) FILTER (
        WHERE job_work_from_home IS FALSE
    ) AS non_remote_rows,
    COUNT(*) FILTER (
        WHERE job_work_from_home IS NULL
    ) AS unknown_remote_status,
    COUNT(*) FILTER (
        WHERE search_date IS NULL
    ) AS missing_search_dates
FROM staging.job_postings;

SELECT
    job_work_from_home,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE job_extensions_raw ILIKE '%remote%'
    ) AS raw_mentions_remote,
    COUNT(*) FILTER (
        WHERE job_detected_extensions_raw ILIKE '%remote%'
    ) AS detected_mentions_remote,
    COUNT(*) FILTER (
        WHERE job_schedule_type IS NOT NULL
    ) AS rows_with_schedule_type
FROM staging.job_postings
GROUP BY job_work_from_home
ORDER BY total_rows DESC;

SELECT
    search_term,
    job_work_from_home,
    COUNT(*) AS total_rows
FROM staging.job_postings
GROUP BY
    search_term,
    job_work_from_home
ORDER BY
    search_term,
    total_rows DESC;

SELECT
    MIN(search_date) AS first_search_date,
    MAX(search_date) AS last_search_date,
    COUNT(DISTINCT search_date) AS days_observed,
    COUNT(*) FILTER (
        WHERE job_work_from_home = FALSE
    ) AS non_remote_rows,
    COUNT(DISTINCT search_location) AS search_locations
FROM staging.job_postings;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids,
    COUNT(*) FILTER (
        WHERE job_id IS NULL
    ) AS null_job_ids,
    COUNT(*) - COUNT(DISTINCT job_id)
        - COUNT(*) FILTER (
            WHERE job_id IS NULL
        ) AS extra_non_null_rows
FROM staging.job_postings;

WITH job_frequency AS (
    SELECT
        job_id,
        COUNT(*) AS observations
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id
)
SELECT
    CASE
        WHEN observations = 1 THEN '1 observation'
        WHEN observations BETWEEN 2 AND 5 THEN '2-5 observations'
        WHEN observations BETWEEN 6 AND 20 THEN '6-20 observations'
        WHEN observations BETWEEN 21 AND 100 THEN '21-100 observations'
        ELSE '100+ observations'
    END AS observation_group,
    COUNT(*) AS number_of_jobs
FROM job_frequency
GROUP BY observation_group
ORDER BY MIN(observations);

SELECT
    COUNT(*) AS total_skill_rows,
    COUNT(DISTINCT job_id) AS jobs_with_skills,
    COUNT(DISTINCT skill_keyword) AS unique_skill_keywords,
    COUNT(DISTINCT skill_id) AS unique_skill_ids,
    COUNT(*) FILTER (
        WHERE job_id IS NULL
    ) AS null_job_ids,
    COUNT(*) FILTER (
        WHERE skill_keyword IS NULL
    ) AS null_skill_keywords
FROM staging.job_skills;

SELECT
    COUNT(DISTINCT s.job_id) AS jobs_in_skills,
    COUNT(DISTINCT s.job_id) FILTER (
        WHERE p.job_id IS NOT NULL
    ) AS matched_jobs,
    COUNT(DISTINCT s.job_id) FILTER (
        WHERE p.job_id IS NULL
    ) AS unmatched_jobs,
    (   SELECT COUNT(DISTINCT p2.job_id)
        FROM staging.job_postings p2
        WHERE p2.job_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM staging.job_skills s2
              WHERE s2.job_id = p2.job_id
          )
    ) AS jobs_without_skills
FROM staging.job_skills s
LEFT JOIN (
    SELECT DISTINCT job_id
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
) p
    ON s.job_id = p.job_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (job_id, skill_keyword))
        AS unique_job_skill_pairs,
    COUNT(*) - COUNT(DISTINCT (job_id, skill_keyword))
        AS duplicate_pairs,
    COUNT(DISTINCT (job_id, skill_id))
        AS unique_job_skill_id_pairs
FROM staging.job_skills;


-- Remote Work Analysis


SELECT
    COUNT(DISTINCT p.job_id) AS remote_jobs,

    COUNT(DISTINCT p.job_id) FILTER (
        WHERE s.job_id IS NOT NULL
    ) AS remote_jobs_with_skills,

    COUNT(DISTINCT p.job_id) FILTER (
        WHERE s.job_id IS NULL
    ) AS remote_jobs_without_skills
FROM staging.job_postings p
LEFT JOIN (
    SELECT DISTINCT job_id
    FROM staging.job_skills
) s
    ON p.job_id = s.job_id
WHERE p.job_work_from_home = TRUE
  AND p.job_id IS NOT NULL;
  SELECT
    search_term,
    COUNT(DISTINCT job_id) AS remote_jobs,
    COUNT(DISTINCT job_id) FILTER (
        WHERE job_id IN (
            SELECT job_id
            FROM staging.job_skills
        )
    ) AS jobs_with_skills
FROM staging.job_postings
WHERE job_work_from_home = TRUE
  AND job_id IS NOT NULL
GROUP BY search_term
ORDER BY remote_jobs DESC;

WITH remote_job_terms AS (
    SELECT
        job_id,
        COUNT(DISTINCT search_term) AS term_count
    FROM staging.job_postings
    WHERE job_work_from_home = TRUE
      AND job_id IS NOT NULL
    GROUP BY job_id
)
SELECT
    term_count,
    COUNT(*) AS number_of_jobs
FROM remote_job_terms
GROUP BY term_count
ORDER BY term_count;

-- Key Investigation

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        job_id,
        search_time,
        search_term,
        search_location
    )) AS unique_observations,

    COUNT(*) - COUNT(DISTINCT (
        job_id,
        search_time,
        search_term,
        search_location
    )) AS duplicate_observations
FROM staging.job_postings
WHERE job_id IS NOT NULL;

SELECT
    job_id,
    search_time,
    search_term,
    search_location,
    COUNT(*) AS occurrences
FROM staging.job_postings
WHERE job_id IS NOT NULL
GROUP BY
    job_id,
    search_time,
    search_term,
    search_location
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT *
FROM staging.job_postings
WHERE job_id = '665c811b7d85e8571e2949b0225ee336'
  AND search_time = TIMESTAMPTZ '2026-04-15 08:05:17+03'
  AND search_term = 'Data Engineer'
  AND search_location = 'Illinois, United States';


SELECT
    job_id,
    COUNT(*) AS row_count,
    COUNT(DISTINCT job_title) AS titles,
    COUNT(DISTINCT company_name) AS companies,
    COUNT(DISTINCT job_location) AS locations
FROM staging.job_postings
WHERE job_id IS NOT NULL
GROUP BY job_id
HAVING COUNT(DISTINCT company_name) > 1
ORDER BY companies DESC
LIMIT 20;

WITH job_id_stats AS (
    SELECT
        job_id,
        COUNT(*) AS row_count,
        COUNT(DISTINCT company_name) AS companies
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id
)
SELECT
    COUNT(*) AS total_job_ids,
    COUNT(*) FILTER (
        WHERE companies > 1
    ) AS ids_with_multiple_companies,
    COUNT(*) FILTER (
        WHERE row_count > 1
    ) AS ids_with_multiple_rows,
    MAX(companies) AS max_companies_per_id
FROM job_id_stats;

SELECT
    COUNT(*) AS total_ids,
    COUNT(*) FILTER (
        WHERE titles > 1
    ) AS ids_with_multiple_titles,
    COUNT(*) FILTER (
        WHERE locations > 1
    ) AS ids_with_multiple_locations
FROM (
    SELECT
        job_id,
        COUNT(DISTINCT job_title) AS titles,
        COUNT(DISTINCT job_location) AS locations
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id
) AS job_stats;

SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    job_via,
    job_posted_at,
    job_work_from_home,
    search_time,
    search_date,
    search_term,
    search_location
FROM staging.job_postings
WHERE job_id = '665c811b7d85e8571e2949b0225ee336'
ORDER BY search_time;

WITH job_keys AS (
    SELECT
        job_id,
        company_name,
        job_title,
        COUNT(*) AS row_count
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY
        job_id,
        company_name,
        job_title
)
SELECT
    COUNT(*) AS distinct_candidate_keys,
    SUM(row_count) AS source_rows,
    COUNT(*) FILTER (
        WHERE row_count > 1
    ) AS keys_with_multiple_rows,
    SUM(row_count - 1) FILTER (
        WHERE row_count > 1
    ) AS extra_rows
FROM job_keys;

WITH candidate_keys AS (
    SELECT
        job_id,
        company_name,
        job_title,
        COUNT(*) AS row_count,
        COUNT(DISTINCT search_term) AS search_terms,
        COUNT(DISTINCT search_location) AS search_locations,
        COUNT(DISTINCT job_via) AS sources,
        COUNT(DISTINCT job_work_from_home) AS remote_statuses
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY
        job_id,
        company_name,
        job_title
)
SELECT
    COUNT(*) AS candidate_keys,
    COUNT(*) FILTER (
        WHERE search_terms > 1
    ) AS keys_multiple_search_terms,
    COUNT(*) FILTER (
        WHERE search_locations > 1
    ) AS keys_multiple_search_locations,
    COUNT(*) FILTER (
        WHERE sources > 1
    ) AS keys_multiple_sources,
    COUNT(*) FILTER (
        WHERE remote_statuses > 1
    ) AS keys_multiple_remote_statuses
FROM candidate_keys;

WITH candidate_keys AS (
    SELECT
        job_id,
        company_name,
        job_title,
        COUNT(DISTINCT job_location) AS locations,
        COUNT(DISTINCT job_schedule_type) AS schedules,
        COUNT(DISTINCT job_salary) AS salaries
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id, company_name, job_title
)
SELECT
    COUNT(*) AS candidate_keys,
    COUNT(*) FILTER (WHERE locations > 1)
        AS keys_multiple_job_locations,
    COUNT(*) FILTER (WHERE schedules > 1)
        AS keys_multiple_schedules,
    COUNT(*) FILTER (WHERE salaries > 1)
        AS keys_multiple_salaries
FROM candidate_keys;

SELECT
    COUNT(*) AS job_ids,
    COUNT(*) FILTER (
        WHERE companies > 1
    ) AS ids_multiple_companies,
    COUNT(*) FILTER (
        WHERE titles > 1
    ) AS ids_multiple_titles
FROM (
    SELECT
        job_id,
        COUNT(DISTINCT company_name) AS companies,
        COUNT(DISTINCT job_title) AS titles
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
    GROUP BY job_id
) AS id_check;

SELECT
    job_id,
    COUNT(*) AS skill_rows,
    COUNT(DISTINCT skill_keyword) AS unique_skills
FROM staging.job_skills
WHERE job_id = '665c811b7d85e8571e2949b0225ee336'
GROUP BY job_id;

WITH jobs AS (
    SELECT DISTINCT
        job_id,
        job_work_from_home
    FROM staging.job_postings
    WHERE job_id IS NOT NULL
),
jobs_with_skills AS (
    SELECT DISTINCT job_id
    FROM staging.job_skills
)
SELECT
    j.job_work_from_home,
    COUNT(*) AS total_jobs,
    COUNT(*) FILTER (
        WHERE s.job_id IS NULL
    ) AS jobs_without_skills
FROM jobs j
LEFT JOIN jobs_with_skills s
    ON j.job_id = s.job_id
GROUP BY j.job_work_from_home
ORDER BY j.job_work_from_home;