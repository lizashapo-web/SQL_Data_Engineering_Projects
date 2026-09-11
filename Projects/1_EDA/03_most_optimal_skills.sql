/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/

SELECT 
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median,
    COUNT(jpf.*) AS popular,
    ROUND((LN(popular) * median) / 100_000, 0) AS optimal
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL
    AND jpf.job_work_from_home = TRUE
GROUP BY 
    sd.skills
HAVING 
    COUNT(sd.skills) >= 100
ORDER BY 
    optimal DESC
LIMIT 10;

/*
Here's a breakdown of the most optimal skills for Data Engineers, based on both high demand and high salaries:

Top Skills by Optimal Score:
- Terraform leads the list with a $184K median salary and 193 postings, resulting in the highest overall "optimal score".
- Python and SQL dominate demand (over 1100 postings each), with strong median salaries of $135K and $130K, respectively.
- AWS (783 postings, $137K median), Spark (503 postings, $140K median), and Airflow (386 postings, $150K median) are all highly sought-after cloud and big data technologies.
- Kafka offers high compensation ($145K median) and solid demand (292 postings).
- Tools like Snowflake, Azure, and Databricks each have 250–475 postings and median salaries between $128–$137K.

DevOps & Engineering Tools:
- Airflow ($150K), Kubernetes ($150.5K), and Docker ($135K) stand out for their mix of demand and top median salaries.
- Git ($140K/208 postings) and Github ($135K/127 postings) have broad utility and competitive compensation.

Noteworthy Languages:
- Java (303 postings, $135K median) and Scala (247 postings, $137K median) remain strong choices for well-paid data engineering roles.
- Go ($140K/113 postings) is another programming language with excellent compensation.

Databases & Cloud:
- Redshift ($130K/274 postings), GCP ($136K/196 postings), Hadoop ($135K/198 postings), NoSQL ($134.4K/193 postings), and MongoDB ($135.8K/136 postings) add to a well-rounded data engineering skill set.
- R, Pyspark, and BigQuery each deliver competitive salaries and meet the threshold for demand.

Summary:
Skills that consistently appear near the top balance a strong combination of market demand (job security) and financial benefit. Python, SQL, AWS, Spark, Airflow, and Terraform are particularly strategic for both immediate opportunities and longer-term career growth in data engineering.

┌────────────┬──────────┬─────────┬─────────┐
│   skills   │  median  │ popular │ optimal │
│  varchar   │  double  │  int64  │ double  │
├────────────┼──────────┼─────────┼─────────┤
│ terraform  │ 184000.0 │     193 │    10.0 │
│ aws        │ 137320.0 │     783 │     9.0 │
│ python     │ 135000.0 │    1133 │     9.0 │
│ spark      │ 140000.0 │     503 │     9.0 │
│ sql        │ 130000.0 │    1128 │     9.0 │
│ airflow    │ 150000.0 │     386 │     9.0 │
│ kubernetes │ 150500.0 │     147 │     8.0 │
│ java       │ 135000.0 │     303 │     8.0 │
│ kafka      │ 145000.0 │     292 │     8.0 │
│ azure      │ 128000.0 │     475 │     8.0 │
└────────────┴──────────┴─────────┴─────────┘
*/