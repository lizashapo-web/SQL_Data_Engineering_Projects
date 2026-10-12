# Project 2: Data Warehouse and Data Mart Build

## Overview

This project builds a DuckDB data warehouse and an analytical data mart for exploring remote Data Engineer job postings and their associated technical skills.

The workflow covers source-data auditing, warehouse table creation, data transformation, mart construction, quality checks, and SQL analysis.

## Business Questions

- Which technical skills appear most often in remote Data Engineer job postings?
- How are skills distributed across the collected remote-job sample?
- Which skills are most relevant to candidates exploring remote Data Engineer roles?

## Tech Stack

- **SQL** — data auditing, transformations, modeling, validation, and analysis
- **DuckDB** — local analytical database
- **Git and GitHub** — version control and project documentation

## Data Sources

The project uses job-posting and skill data from the source dataset used in this repository. The analysis is limited to the records available in that dataset; it should not be interpreted as a complete census of the job market.

## Data Volume

The source-data audit reported:

| Dataset / metric | Rows or count |
|---|---:|
| Source job postings | 691,950 |
| Distinct non-null source job IDs | 491,140 |
| Source job-skill records | 3,304,574 |
| Remote candidates before ambiguous-ID exclusion | 32,761 |
| Final remote job IDs in the mart | 32,760 |
| Final mart rows | 262,171 |
| Job-skill rows in the mart | 260,155 |
| Rows representing jobs without skills | 2,016 |

The remote-candidate count is reduced from 32,761 to 32,760 because one ambiguous job ID is excluded during preparation. The final mart contains 262,171 rows: 260,155 job-skill rows and 2,016 rows retained for jobs with no associated skills.

## Data Pipeline

The pipeline is organized into sequential SQL scripts:

1. **Audit source data** — inspect source tables, counts, missing values, and key uniqueness.
2. **Create warehouse tables** — establish the target tables and their structure.
3. **Transform warehouse data** — clean and transform the source data for analysis.
4. **Build the data mart** — select remote-job records and connect them to their skills.
5. **Test the mart** — validate key assumptions and data quality.
6. **Analyze remote skills** — aggregate skills and identify the most frequent ones.

## Architecture

```text
Source tables
    |
    v
00_data_audit.sql
    |
    v
01_create_tables_dw.sql
    |
    v
02_transform_warehouse.sql
    |
    v
03_data_mart.sql
    |
    v
04_test_mart.sql
    |
    v
05_remote_skills_analysis.sql
    |
    v
Remote Data Engineer skills analysis
```

The `build_marts.sql` script is the convenience entry point that runs the mart-building scripts in sequence. The audit and analysis scripts can also be run individually when needed.

## Data Modeling and Quality

The mart is designed around remote job postings and their associated skills. A job can be associated with multiple skills, so a job may appear in multiple job-skill rows.

The model also preserves remote jobs that have no associated skills. These records are represented separately from job-skill matches, which is why the total mart row count is greater than the number of distinct remote job IDs.

Quality checks include:

- verifying expected row counts;
- checking uniqueness of job-skill pairs;
- checking for duplicate job-skill records;
- checking that mart rows have evidence of remote work;
- reviewing the handling of jobs without associated skills;
- excluding one ambiguous job ID from the final remote-job set.

## Data Mart

The final mart contains **262,171 rows**:

- **260,155** job-skill rows;
- **2,016** rows for jobs without associated skills.

The final remote-job set contains **32,760 unique job IDs**. The checks found no duplicate job-skill pairs and no mart rows without remote-work evidence.

## Analysis and Findings

The ten most frequent skills in the analyzed remote Data Engineer sample are:

| Rank | Skill | Count |
|---:|---|---:|
| 1 | Python | 19,861 |
| 2 | SQL | 18,557 |
| 3 | AWS | 10,578 |
| 4 | Azure | 8,771 |
| 5 | Snowflake | 6,114 |
| 6 | Google Cloud Platform (GCP) | 5,548 |
| 7 | Spark | 5,366 |
| 8 | Databricks | 4,836 |
| 9 | Go | 4,485 |
| 10 | Airflow | 4,447 |

Python and SQL are the most frequent skills in this sample. Cloud platforms and data-processing technologies also appear prominently.

These counts describe occurrences in the collected sample, not the percentage of all jobs in the market. A single job can contribute multiple skill records.


## Data Quality Tests

The project includes SQL-based data quality checks in `04_test_mart.sql`.

### Automated Assertions

The script contains seven automated assertions:

| Test | Validation |
|---|---|
| TEST 7 | Valid job-skill row structure, including jobs without skills |
| TEST 8 | No duplicate job-skill pairs |
| TEST 9 | Every mart row has remote-work evidence |
| TEST 10 | No NULL job IDs in the mart |
| TEST 11 | Row counts reconcile between rows with and without skills |
| TEST 12 | Mart job IDs match the expected eligible job ID set |
| TEST 13 | Each job ID maps to a single company and job title combination |

The assertions return `PASS` when their conditions are satisfied and raise an error when a condition fails.

### Additional Diagnostic Checks

The script also reports:
- Total mart rows and distinct job IDs.
- The number of jobs without associated skills.
- The number of distinct job-skill pairs and duplicate pairs.
- Rows without remote-work evidence.
- NULL job IDs in the source warehouse table.
- Reconciliation of total rows with the rows that have skills and those that do not.

Source-level NULL job IDs are reported for diagnostic purposes and are not the same as NULL job IDs in the final mart.

### Current Validation Results

For the current dataset snapshot, the successful pipeline run produced:

- **32,760** unique job IDs in the mart.
- **262,171** total mart rows.
- **260,155** rows with skills.
- **2,016** rows representing jobs without skills.
- **0** duplicate job-skill pairs.
- **0** mart rows without remote-work evidence.
- **0** NULL job IDs in the mart.

These figures describe the current dataset snapshot. They are not all fixed thresholds used by the automated assertions.

### Running the Tests

From the repository root, open the DuckDB database and run the pipeline first:

```sql
.read Projects/2_DW_Mart_Build/build_marts.sql
```

Then run the data quality checks:

```sql
.read Projects/2_DW_Mart_Build/04_test_mart.sql
```

Review the diagnostic outputs and confirm that all seven automated assertions return `PASS`.


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

Database files are generated locally and are not required to be committed to Git.

## How to Run

Run the commands from the **repository root**.

### 1. Open the project database

In Git Bash or another terminal with DuckDB installed:

```bash
duckdb Projects/2_DW_Mart_Build/dw_marts.duckdb
```

If the database file does not exist yet, DuckDB creates it when it can write to that path.

### 2. Build the mart

At the DuckDB prompt, run:

```sql
.read Projects/2_DW_Mart_Build/build_marts.sql
```

The script runs the mart-building SQL scripts in sequence. If you want to inspect the workflow step by step, execute the individual scripts in their numbered order instead.

### 3. Run the analysis

At the DuckDB prompt, run:

```sql
.read Projects/2_DW_Mart_Build/05_remote_skills_analysis.sql
```

### 4. Run the data quality checks

At the DuckDB prompt, run:

```sql
.read Projects/2_DW_Mart_Build/04_test_mart.sql
```

> Run SQL commands at the DuckDB prompt, not directly at the Git Bash prompt. The `.read` command is a DuckDB CLI command.

## Limitations

- The analysis represents the dataset collected for this project, not the entire job market.
- `search_date` is the date the record was collected by the search process; it is **not** necessarily the job publication date.
- Skill counts measure occurrences in the collected job-skill data. They should not be interpreted as the share of all market vacancies requiring a skill.
- Results depend on the source data, its coverage, and the project's remote-job filtering rules.

## Conclusion

This project demonstrates a SQL-based analytical workflow in DuckDB: auditing source data, creating and transforming warehouse tables, building a data mart, validating data quality, and analyzing technical-skill demand in a sample of remote Data Engineer job postings.

**Project Focus:** SQL · DuckDB · Data Engineering · Data Warehousing · Data Quality · Data Modeling · Data Mart · Data Analysis
