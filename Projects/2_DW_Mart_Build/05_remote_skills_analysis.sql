-- =========================================================
-- Project: Remote Work Skills Intelligence
-- File: 05_remote_skills_analysis.sql
-- Purpose: Analyze the most demanded skills in remote jobs
-- =========================================================

SELECT
    skill_keyword,
    COUNT(DISTINCT job_id) AS candidate_jobs
FROM mart.job_postings_flat
WHERE skill_keyword IS NOT NULL
GROUP BY skill_keyword
ORDER BY candidate_jobs DESC
LIMIT 20;

-- =========================================================
-- ANALYSIS 2: TOP SKILLS BY SEARCH DIRECTION
-- =========================================================

WITH ranked_skills AS (
    SELECT
        search_term,
        skill_keyword,
        COUNT(DISTINCT job_id) AS candidate_jobs,
        ROW_NUMBER() OVER (
            PARTITION BY search_term
            ORDER BY COUNT(DISTINCT job_id) DESC
        ) AS skill_rank
    FROM mart.job_postings_flat
    WHERE skill_keyword IS NOT NULL
      AND search_term IN (
          'Data Analyst',
          'Data Engineer',
          'Data Scientist'
      )
    GROUP BY
        search_term,
        skill_keyword
)
SELECT
    search_term,
    skill_rank,
    skill_keyword,
    candidate_jobs
FROM ranked_skills
WHERE skill_rank <= 10
ORDER BY
    search_term,
    skill_rank;

-- =========================================================
-- ANALYSIS 3: SKILL PREVALENCE BY SEARCH DIRECTION
-- =========================================================

WITH job_totals AS (
    SELECT
        search_term,
        COUNT(DISTINCT job_id) AS total_jobs
    FROM mart.job_postings_flat
    WHERE search_term IN (
        'Data Analyst',
        'Data Engineer',
        'Data Scientist'
    )
    GROUP BY search_term
),

skill_counts AS (
    SELECT
        search_term,
        skill_keyword,
        COUNT(DISTINCT job_id) AS jobs_with_skill
    FROM mart.job_postings_flat
    WHERE skill_keyword IS NOT NULL
      AND search_term IN (
          'Data Analyst',
          'Data Engineer',
          'Data Scientist'
      )
    GROUP BY
        search_term,
        skill_keyword
)

SELECT
    s.search_term,
    s.skill_keyword,
    s.jobs_with_skill,
    t.total_jobs,
    ROUND(
        100.0 * s.jobs_with_skill / t.total_jobs,
        2
    ) AS skill_prevalence_pct
FROM skill_counts s
JOIN job_totals t
    ON s.search_term = t.search_term
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY s.search_term
    ORDER BY s.jobs_with_skill DESC
) <= 10
ORDER BY
    s.search_term,
    skill_prevalence_pct DESC;

-- =========================================================
-- ANALYSIS 4: MONTHLY SKILL PREVALENCE
-- Data Engineer
-- =========================================================

WITH monthly_jobs AS (
    SELECT
        DATE_TRUNC('month', search_date)::DATE AS month,
        COUNT(DISTINCT job_id) AS total_jobs
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
    GROUP BY 1
),

monthly_skills AS (
    SELECT
        DATE_TRUNC('month', search_date)::DATE AS month,
        skill_keyword,
        COUNT(DISTINCT job_id) AS jobs_with_skill
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND skill_keyword IN (
          'python',
          'sql',
          'aws',
          'azure',
          'snowflake'
      )
    GROUP BY 1, 2
)

SELECT
    s.month,
    s.skill_keyword,
    s.jobs_with_skill,
    j.total_jobs,
    ROUND(
        100.0 * s.jobs_with_skill / j.total_jobs,
        2
    ) AS skill_prevalence_pct
FROM monthly_skills s
JOIN monthly_jobs j USING (month)
ORDER BY s.month, s.skill_keyword;

SELECT
    DATE_TRUNC('month', search_date)::DATE AS month,
    COUNT(DISTINCT job_id) AS total_jobs,
    COUNT(DISTINCT search_date) AS collection_days,
    MIN(search_date) AS first_collection_date,
    MAX(search_date) AS last_collection_date
FROM mart.job_postings_flat
WHERE search_term = 'Data Engineer'
GROUP BY 1
ORDER BY 1;

SELECT
    search_date,
    COUNT(DISTINCT job_id) AS total_jobs
FROM mart.job_postings_flat
WHERE search_term = 'Data Engineer'
GROUP BY search_date
ORDER BY search_date;

-- ANALYSIS 5: COLLECTION PATTERNS BY DAY OF WEEK

SELECT
    DAYNAME(search_date) AS day_of_week,
    DAYOFWEEK(search_date) AS day_number,
    COUNT(DISTINCT search_date) AS days_observed,
    ROUND(
        AVG(daily_jobs),
        2
    ) AS avg_jobs_per_day
FROM (
    SELECT
        search_date,
        COUNT(DISTINCT job_id) AS daily_jobs
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
    GROUP BY search_date
) daily
GROUP BY 1, 2
ORDER BY 2;

SELECT
    COUNT(*) AS candidate_jobs,
    COUNT(*) FILTER (
        WHERE observation_count > 1
    ) AS jobs_seen_multiple_times,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE observation_count > 1
        ) / COUNT(*),
        2
    ) AS pct_seen_multiple_times,
    ROUND(AVG(observation_count), 2) AS avg_observations_per_job,
    MAX(observation_count) AS max_observations
FROM warehouse.job_candidates c
WHERE c.remote_observation_count > 0
  AND NOT EXISTS (
      SELECT 1
      FROM (
          SELECT job_id
          FROM warehouse.job_postings
          WHERE job_id IS NOT NULL
          GROUP BY job_id
          HAVING COUNT(DISTINCT company_name) > 1
              OR COUNT(DISTINCT job_title) > 1
      ) a
      WHERE a.job_id = c.job_id
  );

SELECT
    CASE
        WHEN observation_count = 1 THEN '1 observation'
        WHEN observation_count BETWEEN 2 AND 5 THEN '2-5 observations'
        WHEN observation_count BETWEEN 6 AND 30 THEN '6-30 observations'
        ELSE '31+ observations'
    END AS observation_group,
    COUNT(*) AS candidate_jobs,
    SUM(observation_count) AS total_observations,
    ROUND(
        100.0 * SUM(observation_count)
        / SUM(SUM(observation_count)) OVER (),
        2
    ) AS pct_of_all_observations
FROM warehouse.job_candidates c
WHERE c.remote_observation_count > 0
  AND NOT EXISTS (
      SELECT 1
      FROM (
          SELECT job_id
          FROM warehouse.job_postings
          WHERE job_id IS NOT NULL
          GROUP BY job_id
          HAVING COUNT(DISTINCT company_name) > 1
              OR COUNT(DISTINCT job_title) > 1
      ) a
      WHERE a.job_id = c.job_id
  )
GROUP BY 1
ORDER BY
    CASE observation_group
        WHEN '1 observation' THEN 1
        WHEN '2-5 observations' THEN 2
        WHEN '6-30 observations' THEN 3
        ELSE 4
    END;

SELECT
    CASE
        WHEN DATE_DIFF(
            'day', first_seen_date, last_seen_date
        ) = 0 THEN 'Same day'
        WHEN DATE_DIFF(
            'day', first_seen_date, last_seen_date
        ) BETWEEN 1 AND 7 THEN '1-7 days'
        WHEN DATE_DIFF(
            'day', first_seen_date, last_seen_date
        ) BETWEEN 8 AND 30 THEN '8-30 days'
        WHEN DATE_DIFF(
            'day', first_seen_date, last_seen_date
        ) BETWEEN 31 AND 90 THEN '31-90 days'
        ELSE '91+ days'
    END AS observation_span,
    COUNT(*) AS candidate_jobs,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_jobs
FROM warehouse.job_candidates c
WHERE c.remote_observation_count > 0
  AND NOT EXISTS (
      SELECT 1
      FROM (
          SELECT job_id
          FROM warehouse.job_postings
          WHERE job_id IS NOT NULL
          GROUP BY job_id
          HAVING COUNT(DISTINCT company_name) > 1
              OR COUNT(DISTINCT job_title) > 1
      ) a
      WHERE a.job_id = c.job_id
  )
GROUP BY 1
ORDER BY
    CASE observation_span
        WHEN 'Same day' THEN 1
        WHEN '1-7 days' THEN 2
        WHEN '8-30 days' THEN 3
        WHEN '31-90 days' THEN 4
        ELSE 5
    END;

-- =========================================================
-- ANALYSIS 6: SKILL PREVALENCE BY QUARTER
-- Data Engineer: first vs last quarter
-- =========================================================

WITH quarterly_jobs AS (
    SELECT
        CASE
            WHEN search_date < DATE '2025-10-01'
                THEN 'Q1: Jul-Sep 2025'
            ELSE 'Q4: Apr-Jun 2026'
        END AS period,
        COUNT(DISTINCT job_id) AS total_jobs
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND (
          search_date BETWEEN DATE '2025-07-01'
                          AND DATE '2025-09-30'
          OR
          search_date BETWEEN DATE '2026-04-01'
                          AND DATE '2026-06-30'
      )
    GROUP BY 1
),

quarterly_skills AS (
    SELECT
        CASE
            WHEN search_date < DATE '2025-10-01'
                THEN 'Q1: Jul-Sep 2025'
            ELSE 'Q4: Apr-Jun 2026'
        END AS period,
        skill_keyword,
        COUNT(DISTINCT job_id) AS jobs_with_skill
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND skill_keyword IN (
          'python', 'sql', 'aws', 'azure', 'snowflake'
      )
      AND (
          search_date BETWEEN DATE '2025-07-01'
                          AND DATE '2025-09-30'
          OR
          search_date BETWEEN DATE '2026-04-01'
                          AND DATE '2026-06-30'
      )
    GROUP BY 1, 2
),

prevalence AS (
    SELECT
        s.period,
        s.skill_keyword,
        s.jobs_with_skill,
        j.total_jobs,
        ROUND(
            100.0 * s.jobs_with_skill / j.total_jobs,
            2
        ) AS prevalence_pct
    FROM quarterly_skills s
    JOIN quarterly_jobs j USING (period)
)

SELECT
    skill_keyword,
    MAX(total_jobs) FILTER (
        WHERE period = 'Q1: Jul-Sep 2025'
    ) AS q1_total_jobs,
    MAX(prevalence_pct) FILTER (
        WHERE period = 'Q1: Jul-Sep 2025'
    ) AS q1_prevalence_pct,
    MAX(total_jobs) FILTER (
        WHERE period = 'Q4: Apr-Jun 2026'
    ) AS q4_total_jobs,
    MAX(prevalence_pct) FILTER (
        WHERE period = 'Q4: Apr-Jun 2026'
    ) AS q4_prevalence_pct,
    ROUND(
        MAX(prevalence_pct) FILTER (
            WHERE period = 'Q4: Apr-Jun 2026'
        )
        -
        MAX(prevalence_pct) FILTER (
            WHERE period = 'Q1: Jul-Sep 2025'
        ),
        2
    ) AS change_percentage_points
FROM prevalence
GROUP BY skill_keyword
ORDER BY change_percentage_points DESC;

-- =========================================================
-- ANALYSIS 7: SKILL PREVALENCE BY FIRST-SEEN COHORT
-- Data Engineer: first vs last quarter
-- =========================================================

WITH cohort_jobs AS (
    SELECT
        CASE
            WHEN first_seen_date BETWEEN DATE '2025-07-01'
                                     AND DATE '2025-09-30'
                THEN 'Q1: Jul-Sep 2025'
            WHEN first_seen_date BETWEEN DATE '2026-04-01'
                                     AND DATE '2026-06-30'
                THEN 'Q4: Apr-Jun 2026'
        END AS period,
        COUNT(DISTINCT job_id) AS total_jobs
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND (
          first_seen_date BETWEEN DATE '2025-07-01'
                              AND DATE '2025-09-30'
          OR
          first_seen_date BETWEEN DATE '2026-04-01'
                              AND DATE '2026-06-30'
      )
    GROUP BY 1
),

cohort_skills AS (
    SELECT
        CASE
            WHEN first_seen_date BETWEEN DATE '2025-07-01'
                                     AND DATE '2025-09-30'
                THEN 'Q1: Jul-Sep 2025'
            WHEN first_seen_date BETWEEN DATE '2026-04-01'
                                     AND DATE '2026-06-30'
                THEN 'Q4: Apr-Jun 2026'
        END AS period,
        skill_keyword,
        COUNT(DISTINCT job_id) AS jobs_with_skill
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND skill_keyword IN (
          'python', 'sql', 'aws', 'azure', 'snowflake'
      )
      AND (
          first_seen_date BETWEEN DATE '2025-07-01'
                              AND DATE '2025-09-30'
          OR
          first_seen_date BETWEEN DATE '2026-04-01'
                              AND DATE '2026-06-30'
      )
    GROUP BY 1, 2
),

prevalence AS (
    SELECT
        s.period,
        s.skill_keyword,
        j.total_jobs,
        ROUND(
            100.0 * s.jobs_with_skill / j.total_jobs,
            2
        ) AS prevalence_pct
    FROM cohort_skills s
    JOIN cohort_jobs j USING (period)
)

SELECT
    skill_keyword,
    MAX(total_jobs) FILTER (
        WHERE period = 'Q1: Jul-Sep 2025'
    ) AS q1_total_jobs,
    MAX(prevalence_pct) FILTER (
        WHERE period = 'Q1: Jul-Sep 2025'
    ) AS q1_prevalence_pct,
    MAX(total_jobs) FILTER (
        WHERE period = 'Q4: Apr-Jun 2026'
    ) AS q4_total_jobs,
    MAX(prevalence_pct) FILTER (
        WHERE period = 'Q4: Apr-Jun 2026'
    ) AS q4_prevalence_pct,
    ROUND(
        MAX(prevalence_pct) FILTER (
            WHERE period = 'Q4: Apr-Jun 2026'
        ) -
        MAX(prevalence_pct) FILTER (
            WHERE period = 'Q1: Jul-Sep 2025'
        ),
        2
    ) AS change_percentage_points
FROM prevalence
GROUP BY skill_keyword
ORDER BY change_percentage_points DESC;

-- =========================================================
-- ANALYSIS 8: MONTHLY SKILL PREVALENCE
-- Data Engineer | First-seen month
-- =========================================================

CREATE OR REPLACE TABLE mart.monthly_de_skill_prevalence AS

WITH monthly_jobs AS (
    SELECT
        DATE_TRUNC('month', first_seen_date)::DATE AS month,
        COUNT(DISTINCT job_id) AS total_jobs
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND first_seen_date BETWEEN DATE '2025-07-01'
                              AND DATE '2026-06-30'
    GROUP BY 1
),

monthly_skills AS (
    SELECT
        DATE_TRUNC('month', first_seen_date)::DATE AS month,
        skill_keyword,
        COUNT(DISTINCT job_id) AS jobs_with_skill
    FROM mart.job_postings_flat
    WHERE search_term = 'Data Engineer'
      AND skill_keyword IN (
          'python', 'sql', 'aws', 'azure', 'snowflake'
      )
      AND first_seen_date BETWEEN DATE '2025-07-01'
                              AND DATE '2026-06-30'
    GROUP BY 1, 2
)

SELECT
    j.month,
    s.skill_keyword,
    s.jobs_with_skill,
    j.total_jobs,
    ROUND(
        100.0 * s.jobs_with_skill / j.total_jobs,
        2
    ) AS skill_prevalence_pct
FROM monthly_jobs j
JOIN monthly_skills s USING (month);

SELECT *
FROM mart.monthly_de_skill_prevalence
ORDER BY month, skill_keyword;

SELECT
    month,
    skill_keyword,
    skill_prevalence_pct
FROM mart.monthly_de_skill_prevalence
ORDER BY month, skill_keyword;