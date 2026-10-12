# Remote Work Skills Intelligence

## Overview

**Remote Work Skills Intelligence** is a SQL-based data engineering and analytics project that explores skill demand across remote Data Analyst, Data Engineer, and Data Scientist job postings collected between July 2025 and June 2026.

The project demonstrates an end-to-end analytical workflow: auditing raw data, building a Data Warehouse, transforming job observations, creating a Data Mart, validating data quality, and analyzing skill demand across job roles.

The goal is to turn raw job-posting data into a structured dataset that can support career research and data-driven decisions about which technical skills to learn.

## Business Questions

- Which technical skills appear most frequently in remote job postings?
- How does skill demand differ between Data Analysts, Data Engineers, and Data Scientists?
- Which programming languages, cloud platforms, and data tools are most relevant to each role?
- How does observed skill demand change over the collection period?
- How can data quality issues affect the reliability of job-market analysis?

## Tech Stack

- **SQL** — data transformation, aggregation, analysis, and validation
- **DuckDB** — analytical database and SQL execution engine
- **Parquet** — source data storage
- **Git and GitHub** — version control and project documentation

## Data

The project uses job-posting and skill data collected between **July 2025 and June 2026**.

The source data includes job attributes such as job title, company, location, search term, collection date, and remote-work status, alongside skill keywords associated with job IDs.

### Data volume

| Dataset | Rows |
|---|---:|
| Job postings in staging | 691,950 |
| Job-skill records in staging | 3,304,574 |
| Unique job IDs with remote-work evidence | 32,761 |
| Remote job IDs with associated skills | 30,744 |
| Remote job IDs without associated skills | 2,017 |

The Data Warehouse retains the source observations rather than treating every repeated job ID as a separate job opportunity. The analytical layer applies additional eligibility and deduplication rules.

## Data Pipeline

The pipeline is organized into six stages:

1. **Data Audit** — inspect source data, identify missing values, examine duplicate observations, and assess identifier quality.
2. **Load the Data Warehouse** — load the source datasets into the warehouse.
3. **Transform the Data Warehouse** — prepare job observations and candidate-level records for analysis.
4. **Create the Data Mart** — build a flat analytical table combining eligible job records with their associated skills.
5. **Test the Data Mart** — validate key assumptions and check for data quality issues.
6. **Analyze Remote Job Openings** — run SQL analyses to compare skill demand across roles and examine temporal patterns.

### Architecture

```text
Raw Parquet Data
       |
       v
   Data Audit
       |
       v
    Staging
       |
       v
 Data Warehouse
       |
       v
 Transformations
       |
       v
    Data Mart
       |
       v
 Data Quality Tests
       |
       v
 Skill Demand Analysis
```

## Data Modeling and Quality

An important part of this project is deciding how to represent job postings without losing information or introducing misleading counts.

### Key data quality decisions

- **Remote-work eligibility:** include records with explicit `job_work_from_home = TRUE` evidence. A `NULL` remote-work status is treated as unknown, not as `FALSE`.
- **Jobs without skills:** retain eligible remote jobs even when no skills are associated with them. This preserves the distinction between missing skill data and a job that does not exist in the dataset.
- **Repeated observations:** preserve observation history in the warehouse and use a candidate-level model for the analytical layer.
- **Ambiguous identifiers:** exclude job IDs associated with conflicting company names or job titles from the Data Mart to avoid unreliable joins.
- **Duplicate job-skill pairs:** validate that the Data Mart does not contain duplicate combinations of job ID and skill keyword.
- **Reconciliation:** compare the expected and actual Data Mart row counts as part of the validation process.

The candidate key based on `job_id`, `company_name`, and `job_title` is a practical modeling choice, not a guarantee that every real-world vacancy has a globally unique identity.

## Data Mart

The `mart.job_postings_flat` table provides a flattened analytical dataset connecting eligible remote job candidates with their skills.

It includes job attributes, observation-related information, remote-work evidence, and skill keywords.

The table uses one row per candidate and skill. Eligible jobs without associated skills are retained as rows with a `NULL` skill value.

This structure supports skill counts, role comparisons, and prevalence calculations while making it possible to account for jobs that have no skill records.

## Analysis and Findings

### Overall skill demand

Among the most frequently observed skills in the remote-job dataset are:

| Skill | Job-skill associations |
|---|---:|
| Python | 19,861 |
| SQL | 18,557 |
| AWS | 10,578 |
| Azure | 8,771 |
| Snowflake | 6,114 |
| Google Cloud Platform | 5,548 |
| Apache Spark | 5,366 |
| Databricks | 4,836 |
| Go | 4,485 |
| Apache Airflow | 4,447 |

These figures represent job-skill associations, not unique vacancies across all skills. A single job can require multiple skills.

### Differences between roles

The role-based analysis highlights different skill profiles:

- **Data Analyst:** SQL, Excel, Python, Tableau, and Power BI are prominent analytical skills.
- **Data Engineer:** Python, SQL, cloud platforms, Snowflake, Spark, Databricks, Kubernetes, and Airflow are prominent.
- **Data Scientist:** Python, SQL, R, machine-learning frameworks, and related data science tools are prominent.

The project also calculates skill prevalence by role, allowing skills to be compared as a percentage of jobs within each role rather than only by raw counts.

### Temporal analysis

Monthly skill-prevalence analysis is used to examine how frequently selected skills appear over the collection period.

Because the dataset reflects collected search results, changes over time should be interpreted as changes in the observed sample. They do not necessarily represent changes across the entire remote-job market.

## Data Quality Tests

The SQL test script checks important properties of the Data Mart, including:

- Total row count and distinct job IDs
- Jobs retained without associated skills
- Duplicate job-skill combinations
- Valid remote-work status values
- Source records with missing job IDs
- Reconciliation between expected and actual Data Mart rows

These checks help detect problems that could otherwise distort analytical results.

## Project Structure

```text
Projects/
└── 2_DW_Mart_Build/
    ├── 00_data_audit.sql
    ├── 01_create_tables_dw.sql
    ├── 02_transform_warehouse.sql
    ├── 03_data_mart.sql
    ├── 04_test_mart.sql
    ├── 05_remote_skills_analysis.sql
    ├── build_marts.sql
    └── README.md
```

## How to Run

### Prerequisites

- DuckDB
- The source data files used by the project
- Git, if cloning the repository

### Steps

1. Clone the repository and open the project directory.

2. Make sure the source data files are available locally and that the paths referenced by the SQL scripts point to their actual locations.

3. Run the pipeline from the repository root using the DuckDB CLI:

   ```sql
   .read Projects/2_DW_Mart_Build/build_marts.sql
   ```

4. Review the output of the Data Mart tests.

5. Run individual queries from `05_remote_skills_analysis.sql` to explore skill rankings, role comparisons, prevalence, and monthly trends.

**Note:** The scripts use relative project paths and may depend on the location of the source files. Update those paths if your local directory structure differs.

## Limitations

- **Collection date versus posting date:** `search_date` represents when a job was observed in the collection process, not necessarily when it was originally published.
- **Repeated and overlapping results:** the same job ID can appear under multiple search terms or in multiple observations. Counts across search terms therefore may overlap.
- **Incomplete skill information:** some jobs have no associated skill records. Their absence from skill-level counts does not mean they require no skills.
- **Uncertain vacancy identity:** a combination of job ID, company, and title is a practical candidate key, but it cannot guarantee perfect real-world deduplication.
- **Sample representativeness:** the collected dataset is not necessarily a complete or unbiased representation of the remote-job market.
- **Temporal interpretation:** observed changes in monthly counts or prevalence should not be interpreted as causal effects or definitive market-wide trends.

## Conclusion

Remote Work Skills Intelligence demonstrates how SQL can be used to build an analytical data pipeline from raw job-posting data to a tested Data Mart and actionable skill-demand analysis.

Beyond querying data, the project focuses on data modeling, handling missing and ambiguous records, validating transformations, and documenting analytical limitations.

The resulting dataset supports a structured comparison of technical skills across remote Data Analyst, Data Engineer, and Data Scientist roles.