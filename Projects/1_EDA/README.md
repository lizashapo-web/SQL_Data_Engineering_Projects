# Data Engineer Skills Analysis

## Table of Contents

- [Project Overview](#project-overview)
- [Analysis Scope](#analysis-scope)
- [Dataset Structure](#dataset-structure)
- [SQL Analysis](#sql-analysis)
  - [Most In-Demand Skills](#1-most-in-demand-skills)
  - [Highest-Paying Skills](#2-highest-paying-skills)
  - [Most Optimal Skills](#3-most-optimal-skills)
- [Overall Conclusions](#overall-conclusions)
- [SQL Concepts Used](#sql-concepts-used)
- [Tools & Technologies](#tools--technologies)
- [Project Structure](#project-structure)

---

## Project Overview

This project analyzes job postings for Data Engineers to identify the skills that are most valuable in the remote job market.

The analysis focuses on three main questions:

1. Which skills are most in demand for Data Engineers?
2. Which skills are associated with the highest median salaries?
3. Which skills provide the best balance between market demand and salary?

The goal is to understand which technical skills are most relevant for Data Engineering career development by considering both job market demand and compensation.

---

## Analysis Scope

The analysis focuses on:

- Data Engineer positions
- Remote job postings
- Skills associated with Data Engineer positions
- Annual salary data where available

The analysis uses SQL to join job postings with skill-related tables and calculate demand, median salary, and a combined skill score.

---

## Dataset Structure

The analysis uses three main tables:

- `job_postings_fact` — job posting information, including job title, remote status, and salary
- `skills_job_dim` — relationship between job postings and skills
- `skills_dim` — skill names

The tables are connected through job and skill IDs.

---

## SQL Analysis

### 1. Most In-Demand Skills

[View SQL query →](./01_top_demanded_skills.sql)

The first analysis identifies the top 10 skills appearing most frequently in remote Data Engineer job postings.

The query:

- filters for `Data Engineer` positions
- filters for remote jobs
- joins job postings with the skills tables
- groups job postings by skill
- counts the number of postings for each skill
- ranks skills by demand

### Results

| Rank | Skill | Job Postings |
|---:|---|---:|
| 1 | SQL | 29,221 |
| 2 | Python | 28,776 |
| 3 | AWS | 17,823 |
| 4 | Azure | 14,143 |
| 5 | Spark | 12,799 |
| 6 | Airflow | 9,996 |
| 7 | Snowflake | 8,639 |
| 8 | Databricks | 8,183 |
| 9 | Java | 7,267 |
| 10 | GCP | 6,446 |

### Key Findings

SQL and Python are clearly the most frequently requested skills, with almost 29,000 job postings each.

Cloud platforms are also highly represented, with AWS and Azure ranking third and fourth.

Apache Spark, Airflow, Snowflake, and Databricks demonstrate strong demand for data processing and data pipeline technologies.

---

## 2. Highest-Paying Skills

[View SQL query →](./02_highest_paying_skills.sql)

The second analysis examines the median annual salary associated with each skill.

Only skills appearing in at least 100 job postings are included. This helps reduce the influence of skills that appear in only a very small number of postings.

The query calculates:

- median annual salary for each skill
- number of job postings associated with each skill
- top 10 skills ranked by median salary

### Results

| Rank | Skill | Median Salary | Job Postings |
|---:|---|---:|---:|
| 1 | Rust | $210,000 | 232 |
| 2 | Golang | $184,000 | 912 |
| 3 | Terraform | $184,000 | 3,248 |
| 4 | Spring | $175,500 | 364 |
| 5 | Neo4j | $170,000 | 277 |
| 6 | GDPR | $169,616 | 582 |
| 7 | Zoom | $168,438 | 127 |
| 8 | GraphQL | $167,500 | 445 |
| 9 | Mongo | $162,250 | 265 |
| 10 | FastAPI | $157,500 | 204 |

### Key Findings

Rust has the highest median salary in the analysis at $210K, but its demand is considerably lower than the most commonly requested Data Engineering skills.

Terraform and Golang also show high median salaries while having substantially more job postings.

This demonstrates that the highest-paying skill is not necessarily the most practical skill to prioritize when considering the size of the job market.

---

## 3. Most Optimal Skills

[View SQL query →](./03_most_optimal_skills.sql)

The final analysis combines salary and demand into a single `optimal` score.

The purpose is to identify skills that provide a strong balance between:

- market demand
- earning potential

The score uses the natural logarithm of skill demand to reduce the dominance of extremely common skills:

`optimal score = LN(demand) × median salary`

A minimum threshold of 100 job postings is applied before ranking the skills.

### Results

| Rank | Skill | Median Salary | Job Postings | Optimal Score |
|---:|---|---:|---:|---:|
| 1 | Terraform | $184,000 | 193 | 10 |
| 2 | AWS | $137,320 | 783 | 9 |
| 3 | Python | $135,000 | 1,133 | 9 |
| 4 | Spark | $140,000 | 503 | 9 |
| 5 | SQL | $130,000 | 1,128 | 9 |
| 6 | Airflow | $150,000 | 386 | 9 |
| 7 | Kubernetes | $150,500 | 147 | 8 |
| 8 | Java | $135,000 | 303 | 8 |
| 9 | Kafka | $145,000 | 292 | 8 |
| 10 | Azure | $128,000 | 475 | 8 |

### Key Findings

The combined analysis highlights skills that offer a balance between demand and compensation.

Terraform ranks first in the optimal-score analysis due to its high median salary combined with meaningful demand.

AWS, Python, SQL, Spark, and Airflow also rank highly, combining strong market demand with competitive salaries.

This suggests that skills such as Python, SQL, AWS, Spark, Airflow, and Terraform can be particularly valuable for Data Engineers who want to combine employability with earning potential.

---

## Overall Conclusions

The analysis shows three different perspectives on Data Engineering skills.

### Most demanded

**SQL, Python, AWS, Azure, and Spark** dominate the remote Data Engineer job market.

### Highest paying

**Rust, Golang, Terraform, Spring, and Neo4j** have some of the highest median salaries among skills meeting the minimum demand threshold.

### Best balance

**Terraform, AWS, Python, Spark, SQL, and Airflow** stand out when both demand and salary are considered together.

The main takeaway is that the highest-paying skill is not necessarily the best skill to learn first. A more useful approach is to consider both the size of the job market and the potential compensation.

---

## SQL Concepts Used

This project demonstrates practical SQL skills including:

- `SELECT`
- `WHERE`
- `INNER JOIN`
- `GROUP BY`
- `HAVING`
- `COUNT()`
- `MEDIAN()`
- `ROUND()`
- `LN()`
- `ORDER BY`
- `LIMIT`
- Table aliases
- Aggregate functions
- Filtering and ranking aggregated data

---

## Tools & Technologies

- SQL
- DuckDB
- MotherDuck
- Visual Studio Code
- GitHub

---

## Project Structure

```text
data-engineer-skills-analysis/
│
├── 01_top_demanded_skills.sql
├── 02_highest_paying_skills.sql
├── 03_most_optimal_skills.sql
└── README.md
```

---