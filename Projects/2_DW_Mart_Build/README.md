# Remote Work Skills Intelligence

## Overview

**Remote Work Skills Intelligence** is a SQL-based Data Engineering and analytics project that explores skill demand across remote Data Analyst, Data Engineer, and Data Scientist job postings collected between July 2025 and June 2026.

The project demonstrates an end-to-end analytical workflow: auditing raw data, building a Data Warehouse, transforming job observations, creating a Data Mart, validating data quality, and analyzing skill demand across job roles.

The goal is to turn raw job-posting data into a structured dataset that supports career research and data-driven decisions about which technical skills to learn.

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

## Data Sources

The project uses job-posting and skill data collected between **July 2025 and June 2026**.

The source data includes job titles, company names, locations, search terms, collection dates, remote-work indicators, and skill keywords associated with job IDs.

### Data volume

| Dataset | Rows |
|---|---:|
| Job postings in staging | 691,950 |
| Job-skill records in staging | 3,304,574 |
| Unique job IDs with remote-work evidence before final exclusions | 32,761 |
| Remote job IDs with associated skills before final exclusions | 30,744 |
| Remote job IDs without associated skills before final exclusions | 2,017 |

The Data Warehouse retains source observations rather than treating every repeated job ID as a separate job opportunity.

The Data Mart applies additional eligibility and deduplication rules. One ambiguous job ID associated with conflicting company names or job titles is excluded from the final analytical dataset.

The final Data Mart contains:

- **32,760 unique job IDs**
- **262,171 total rows**
- **260,155 rows with skill associations**
- **2,016 jobs without associated skills**

The row counts reconcile: 260,155 rows with skills plus 2,016 rows without skills equals 262,171 total rows.

### Source file requirements

The source Parquet files are stored locally and are not included in this repository.

Expected source directory in the original development environment:

```text
D:/dbt_Analytics_Engineering_Course/project_1/data/raw/
```

The directory contains 12 monthly job-posting files, from `raw_job_postings_2025-07.parquet` through `raw_job_postings_2026-06.parquet`, and `raw_job_skills.parquet`.

**Important:** The paths in `00_data_audit.sql` are environment-specific. Update them to match your local source data directory before running the pipeline.

## Data Pipeline

The pipeline consists of six stages.

1. **Data Audit** — inspect source data, identify missing values, examine repeated observations, and assess identifier quality.
2. **Load the Data Warehouse** — load source datasets into warehouse tables.
3. **Transform the Data Warehouse** — prepare job observations and candidate-level records for analysis.
4. **Create the Data Mart** — build an analytical table combining eligible job records with their associated skills.
5. **Test the Data Mart** — validate data quality assumptions and reconcile row counts.
6. **Analyze Remote Job Openings** — compare skill demand across roles and examine observed temporal patterns.

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

The `build_marts.sql` script orchestrates the individual SQL files in the intended execution order.

## Data Modeling and Quality

A central challenge in this project is representing job postings without losing information or introducing misleading counts.

### Key data quality decisions

- **Remote-work eligibility:** Include records with explicit `job_work_from_home = TRUE` evidence. A `NULL` remote-work status is treated as unknown, not as `FALSE`.
- **Jobs without skills:** Retain eligible remote jobs even when no skills are associated with them. Missing skill information does not mean the job itself is missing.
- **Repeated observations:** Preserve observation history in the warehouse and use a candidate-level model in the analytical layer.
- **Ambiguous identifiers:** Exclude job IDs associated with conflicting company names or job titles from the Data Mart to avoid unreliable joins.
- **Duplicate job-skill pairs:** Validate that the Data Mart contains no duplicate combinations of job ID and skill keyword.
- **Reconciliation:** Compare expected and actual Data Mart row counts during validation.

The candidate key based on `job_id`, `company_name`, and `job_title` is a practical modeling choice. It does not guarantee that every real-world vacancy has a globally unique identity.

## Data Mart

The `mart.job_postings_flat` table provides a flattened analytical dataset connecting eligible remote job candidates with their associated skills.

It includes job attributes, observation-related information, remote-work evidence, and skill keywords.

The table uses one row per candidate and skill. Eligible jobs without associated skills are retained as rows with a `NULL` skill value.

This structure supports skill counts, role comparisons, and prevalence calculations while preserving jobs that have no skill records.

## Analysis and Findings

### Overall skill demand

The following skills appeared most frequently in the observed remote-job dataset.

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

These figures represent job-skill associations, not the total number of unique vacancies across all skills. A single job can require multiple skills.

### Differences between roles

The role-based analysis highlights different skill profiles.

- **Data Analyst:** SQL, Excel, Python, Tableau, and Power BI are prominent analytical skills.
- **Data Engineer:** Python, SQL, cloud platforms, Snowflake, Spark, Databricks, Kubernetes, and Airflow are prominent.
- **Data Scientist:** Python, SQL, R, machine-learning frameworks, and related data science tools are prominent.

The project also calculates skill prevalence by role, allowing skills to be compared as a percentage of jobs within each role rather than only by raw counts.

### Temporal analysis

Monthly skill-prevalence analysis examines how frequently selected skills appear throughout the collection period.

Because the dataset reflects collected search results, changes over time should be interpreted as changes in the observed sample. They do not necessarily represent changes across the entire remote-job market.

## Data Quality Tests

The `04_test_mart.sql` script checks important properties of the Data Mart, including:

- Total row count and distinct job IDs.
- Jobs retained without associated skills.
- Duplicate job-skill combinations.
- Remote-work evidence.
- Source records with missing job IDs.
- Reconciliation between Data Mart row counts and their expected components.

The executed validation queries produced results consistent with the project's expected counts:

| Validation metric | Result |
|---|---:|
| Total Data Mart rows | 262,171 |
| Distinct job IDs | 32,760 |
| Jobs without associated skills | 2,016 |
| Rows with skill associations | 260,155 |
| Duplicate job-skill pairs | 0 |
| Rows without remote-work evidence | 0 |

These checks help identify problems that could otherwise distort analytical results. The current test script displays query results rather than generating explicit `PASS` or `FAIL` statuses.

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

The DuckDB database files used during local development are not required to be committed to the repository. The pipeline creates or updates database objects when its scripts are executed.

## How to Run

### Prerequisites

- DuckDB CLI installed and available in the terminal.
- The source Parquet files used by the project.
- Git, if cloning the repository.

### 1. Clone the repository

Run these commands in your terminal:

```bash
git clone https://github.com/lizashapo-web/SQL_Data_Engineering_Projects.git
cd SQL_Data_Engineering_Projects
```

### 2. Configure the source data paths

Open `Projects/2_DW_Mart_Build/00_data_audit.sql`.

Update the absolute file paths to point to your local copies of the source Parquet files.

Make sure all required source files exist before continuing.

### 3. Open the DuckDB database

From the repository root, run:

```bash
duckdb Projects/2_DW_Mart_Build/dw_marts.duckdb
```

If the database file does not exist locally, DuckDB can create it when opening the path.

### 4. Run the complete pipeline

At the DuckDB prompt, execute:

```sql
.read Projects/2_DW_Mart_Build/build_marts.sql
```

The orchestration script runs the data audit, warehouse loading, transformations, Data Mart creation, validation queries, and analytical queries in sequence.

You can also execute individual SQL scripts with `.read` to inspect the results of each stage separately.

Review the validation results and investigate unexpected values before relying on the analytical output.

**Note:** The pipeline depends on the source Parquet files being available at the configured paths. A successful Git clone alone is not sufficient to reproduce the results.

## Limitations

- **Collection date versus posting date:** `search_date` represents when a job was observed during collection, not necessarily when it was originally published.
- **Repeated and overlapping results:** The same job ID can appear under multiple search terms or in multiple observations. Counts across search terms may overlap.
- **Incomplete skill information:** Some jobs have no associated skill records. Their absence from skill-level counts does not mean they require no skills.
- **Uncertain vacancy identity:** A combination of job ID, company, and title is a practical candidate key but cannot guarantee perfect real-world deduplication.
- **Sample representativeness:** The collected dataset is not necessarily a complete or unbiased representation of the remote-job market.
- **Temporal interpretation:** Changes in monthly counts or skill prevalence should not be interpreted as causal effects or definitive market-wide trends.

## Conclusion

Remote Work Skills Intelligence demonstrates how SQL can be used to build an analytical data pipeline from raw job-posting data to a validated Data Mart and skill-demand analysis.

Beyond querying data, the project focuses on data modeling, handling missing and ambiguous records, validating transformations, and documenting analytical limitations.

The resulting dataset supports structured comparisons of technical skills across remote Data Analyst, Data Engineer, and Data Scientist roles.

---

**Project focus:** SQL · DuckDB · Data Engineering · Data Warehousing · Data Quality · Data Modeling · Data Mart · Data Analysis
