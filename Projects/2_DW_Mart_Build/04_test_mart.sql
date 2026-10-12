-- =========================================================
-- Project: Remote Work Skills Intelligence
-- File: 04_test_mart.sql
-- Purpose: Validate the remote job skills mart
-- =========================================================


-- =========================================================
-- TEST 1: MART SIZE AND JOB IDENTIFIERS
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT job_id) AS unique_job_ids
FROM mart.job_postings_flat;


-- =========================================================
-- TEST 2: JOBS WITHOUT SKILLS
-- =========================================================

SELECT
    COUNT(DISTINCT job_id) AS jobs_without_skills
FROM mart.job_postings_flat
WHERE skill_keyword IS NULL;


-- =========================================================
-- TEST 3: DUPLICATE JOB-SKILL PAIRS
-- Expected: zero duplicate pairs
-- =========================================================

SELECT
    COUNT(*) AS skill_rows,
    COUNT(DISTINCT (job_id, skill_keyword))
        AS unique_job_skill_pairs,
    COUNT(*) - COUNT(DISTINCT (job_id, skill_keyword))
        AS duplicate_pairs
FROM mart.job_postings_flat
WHERE skill_keyword IS NOT NULL;


-- =========================================================
-- TEST 4: REMOTE STATUS VALIDATION
-- Expected: zero rows without remote evidence
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE has_remote_evidence IS NOT TRUE
    ) AS rows_without_remote_evidence
FROM mart.job_postings_flat;


-- =========================================================
-- TEST 5: NULL JOB IDs IN SOURCE WAREHOUSE
-- =========================================================

SELECT
    COUNT(*) AS null_job_ids
FROM warehouse.job_postings
WHERE job_id IS NULL;


-- =========================================================
-- TEST 6: CHECK MART ROW COUNT RECONCILIATION
-- Skill rows + rows without skills = total rows
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE skill_keyword IS NOT NULL
    ) AS rows_with_skills,

    COUNT(*) FILTER (
        WHERE skill_keyword IS NULL
    ) AS rows_without_skills,

    COUNT(*) FILTER (
        WHERE skill_keyword IS NOT NULL
    )
    +
    COUNT(*) FILTER (
        WHERE skill_keyword IS NULL
    ) AS reconciled_rows

FROM mart.job_postings_flat;

-- =========================================================
-- AUTOMATED ASSERTIONS
-- The error() function raises an error when a test fails.
-- =========================================================


-- TEST 7: VALID JOB-SKILL ROW STRUCTURE
-- Jobs without skills must have exactly one NULL-skill row.
-- Jobs with skills must not have NULL-skill rows.

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'PASS'
    ELSE error('FAIL: Invalid job-skill row structure')
END AS test_result
FROM (
    SELECT
        job_id,
        COUNT(*) FILTER (
            WHERE skill_keyword IS NULL
        ) AS rows_without_skills,
        COUNT(*) FILTER (
            WHERE skill_keyword IS NOT NULL
        ) AS rows_with_skills
    FROM mart.job_postings_flat
    GROUP BY job_id
    HAVING
        (
            COUNT(*) FILTER (
                WHERE skill_keyword IS NULL
            ) > 0
            AND (
                COUNT(*) FILTER (
                    WHERE skill_keyword IS NULL
                ) <> 1
                OR COUNT(*) FILTER (
                    WHERE skill_keyword IS NOT NULL
                ) > 0
            )
        )
) AS invalid_jobs;


-- TEST 8: NO DUPLICATE JOB-SKILL PAIRS

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'PASS'
    ELSE error('FAIL: Duplicate job-skill pairs found')
END AS test_result
FROM (
    SELECT job_id, skill_keyword
    FROM mart.job_postings_flat
    WHERE skill_keyword IS NOT NULL
    GROUP BY job_id, skill_keyword
    HAVING COUNT(*) > 1
) AS duplicates;


-- TEST 9: ALL MART ROWS HAVE REMOTE EVIDENCE

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'PASS'
    ELSE error('FAIL: Rows without remote evidence found')
END AS test_result
FROM mart.job_postings_flat
WHERE has_remote_evidence IS NOT TRUE;


-- TEST 10: NO NULL JOB IDs IN THE MART

SELECT CASE
    WHEN COUNT(*) = 0 THEN 'PASS'
    ELSE error('FAIL: NULL job_id found in mart')
END AS test_result
FROM mart.job_postings_flat
WHERE job_id IS NULL;