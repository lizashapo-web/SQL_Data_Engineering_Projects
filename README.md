# SQL & Data Engineering Portfolio

Welcome to my SQL and Data Engineering portfolio!

This repository documents my hands-on experience with SQL, data analysis, data modeling, and building analytical data pipelines.

My focus is on developing practical Data Engineering skills through projects involving real datasets, data transformations, data quality validation, and analytical problem-solving.

## Projects

### Project 1 — Exploratory Data Analysis (EDA)

**Focus:** SQL Analytics · Exploratory Data Analysis · Job Market Insights

An SQL-based exploratory analysis of job market data, focusing on identifying valuable technical skills and exploring their relationship with job opportunities and compensation.

**Main analyses:**
- Most in-demand skills in the job market.
- Skills associated with higher-paying positions.
- Optimal skills based on demand and salary considerations.

**SQL scripts:**
- `01_top_demanded_skills.sql`
- `02_highest_paying_skills.sql`
- `03_most_optimal_skills.sql`

[Explore Project 1 →](Projects/1_EDA/README.md)

---

### Project 2 — Data Warehouse & Data Mart: Remote Job Market Analysis

**Focus:** Data Engineering · DuckDB · Data Warehousing · ELT · Data Quality

A multi-stage SQL data pipeline that processes raw job posting and skill data, transforms it into a structured data warehouse, and builds an analytical data mart.

The project analyzes technical skills associated with remote Data Analyst, Data Engineer, and Data Scientist positions.

**Key features:**
- Auditing raw Parquet datasets.
- Creating and transforming data warehouse tables.
- Handling repeated observations and missing values.
- Building a candidate-level analytical data mart.
- Validating data integrity and reconciling row counts.
- Analyzing technical skill prevalence across job roles.
- Executing the complete pipeline using an orchestration SQL script.

**Selected results:**
- 691,950 source job posting observations processed.
- 3,304,574 source job-skill records examined.
- 32,760 unique remote job candidates in the final data mart.
- 260,155 unique job-skill pairs.
- Zero duplicate job-skill pairs in the final data mart.

[Explore Project 2 →](Projects/2_DW_Mart_Build/README.md)

## Tech Stack

| Category | Technologies |
|---|---|
| Querying & Analytics | SQL |
| Analytical Database | DuckDB |
| Data Formats | Parquet |
| Development | Visual Studio Code |
| Version Control | Git, GitHub |

Additional technologies I am exploring include Python, PostgreSQL, MotherDuck, and modern Data Engineering tools.

## Repository Structure

```text
SQL_Data_Engineering_Projects/
├── Projects/
│   ├── 1_EDA/
│   │   ├── 01_top_demanded_skills.sql
│   │   ├── 02_highest_paying_skills.sql
│   │   ├── 03_most_optimal_skills.sql
│   │   └── README.md
│   └── 2_DW_Mart_Build/
│       ├── 00_data_audit.sql
│       ├── 01_create_tables_dw.sql
│       ├── 02_transform_warehouse.sql
│       ├── 03_data_mart.sql
│       ├── 04_test_mart.sql
│       ├── 05_remote_skills_analysis.sql
│       ├── build_marts.sql
│       └── README.md
└── README.md
```

Local DuckDB database files are excluded from the repository through Git ignore rules.

## Skills Demonstrated

- Writing analytical and transformation SQL.
- Working with relational and columnar data.
- Building multi-stage data pipelines.
- Data warehouse and data mart development.
- Data quality auditing and validation.
- Handling duplicates and incomplete data.
- Analytical problem-solving.
- Version control and technical documentation.

## Current Learning Goals

I am continuing to develop my skills in:

- Python for Data Engineering.
- ETL/ELT pipeline development.
- Advanced SQL and query optimization.
- Data warehouse design and dimensional modeling.
- Data orchestration and automated testing.
- Cloud data platforms.

## About This Repository

This portfolio is an ongoing collection of projects and exercises documenting my progress toward a Data Engineering career.

Each project aims to demonstrate not only SQL proficiency, but also the ability to structure data workflows, validate results, explain technical decisions, and communicate findings clearly.