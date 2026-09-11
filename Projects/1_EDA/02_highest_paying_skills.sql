/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities
*/

SELECT 
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median,
    sd.skills,
    COUNT(jpf.*) AS amount
FROM 
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = TRUE
GROUP BY 
    sd.skills
HAVING 
    COUNT(sd.skills) >= 100
ORDER BY median DESC
LIMIT 10;

/*
Here's a breakdown of the highest-paying skills for Data Engineers:

Key Insights:
- Rust remains the top-paying skill at $210K median salary, though demand is still relatively limited (232 postings).
- Terraform and Golang both have high median salaries at $184K, with strong demand (Terraform: 3,248 postings; Golang: 912 postings).
- Other notable skills with both high pay and moderate-to-high frequency include:
  - Spring: $175.5K median salary (364 postings)
  - Neo4j: $170K median salary (277 postings)
  - GDPR: $169.6K median salary (582 postings)
  - GraphQL: $167.5K median salary (445 postings)
  - Kubernetes: $150.5K median salary (4,202 postings)
  - Airflow: $150K median salary (9,996 postings)
- Bitbucket, Ruby, Redis, Ansible, and Jupyter all appear in the top 25 for pay, each with hundreds of postings.
- Most skills on the list are no longer extreme statistical outliers with just a handful of postings; instead, many show consistently strong demand.

Takeaway: While the very top-paying skill (Rust) still has less demand than major cloud and data tools, most of the top-paying skills have both solid salaries and significant demand. This suggests that learning tools like Terraform, Golang, Spring, Neo4j, and especially core data engineering tools (Airflow, Kubernetes) provides a strong balance between compensation and marketability.

┌──────────┬───────────┬────────┐
│  median  │  skills   │ amount │
│  double  │  varchar  │ int64  │
├──────────┼───────────┼────────┤
│ 210000.0 │ rust      │    232 │
│ 184000.0 │ golang    │    912 │
│ 184000.0 │ terraform │   3248 │
│ 175500.0 │ spring    │    364 │
│ 170000.0 │ neo4j     │    277 │
│ 169616.0 │ gdpr      │    582 │
│ 168438.0 │ zoom      │    127 │
│ 167500.0 │ graphql   │    445 │
│ 162250.0 │ mongo     │    265 │
│ 157500.0 │ fastapi   │    204 │
└──────────┴───────────┴────────┘
*/