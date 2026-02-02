# Marketing Campaign & Enrollment Analytics Platform

## Overview

This project implements a layered data warehouse and analytics platform designed to analyze the relationship between marketing campaigns, learner enrollments, opportunities, and cohorts.

The system transforms raw operational data into business-ready analytical views, enabling accurate reporting and dashboarding in Looker Studio.

The solution follows modern data engineering best practices:

- Layered architecture (Raw → Fixed → Clean → Business)

- Data quality enforcement and auditability

- Entity conformance before analytics

- BI-tool-friendly modeling

---

## Business Use Cases

- Measure marketing campaign performance (reach → clicks → conversions)

- Attribute enrollments and opportunities to campaigns

- Analyze learner demographics and enrollment behavior

- Compare campaign efficiency across objectives and time

- Power executive dashboards in Looker Studio

---

## Data Architecture

This project uses a layered data warehouse design to ensure data quality, traceability, and scalability.

### 🔹 Layered Architecture Diagram

**Architecture Summary**

**Raw Layer:** Source-aligned ingestion (no transformations)

**Fixed Layer:** Cleansing, standardization, deduplication, quality flags

**Clean Layer:** Entity composition with controlled joins

**Business Layer:** Analytics-ready master views

**Consumption:** Looker Studio dashboards (read-only)

**Architecture Principles**
- Full-load ingestion using CSV source files
- Truncate & insert strategy for Raw and Fixed layers
- Conformed entities created in Clean layer
- Business Layer exposes read-only master analytics views
- Consumption via Looker Studio dashboards

**Screenshot:**

![Layered Architecture](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Diagrams/Layered%20Data%20Warehouse%20Architecture%20(Raw%20%E2%86%92%20Fixed%20%E2%86%92%20Clean%20%E2%86%92%20Final)%20(Learner%20Dataset).drawio.png)

---

## 🔹 Data Flow Diagram

**Key Concepts**

- Each dataset is independently fixed before composition

- Joins only occur after data quality validation

- Business views are isolated from transformation logic

## Source Datasets

| Dataset             | Description                        |
| ------------------- | ---------------------------------- |
| Learner             | Learner profiles and demographics  |
| Opportunity         | Program / course / event metadata  |
| Learner Opportunity | Enrollment and application records |
| Cohort              | Cohort structure and lifecycle     |
| Cognito             | User authentication & profile data |
| Marketing Campaign  | Campaign performance metrics       |

## Layer Breakdown

### 🟤 Raw Layer

- Tables mirror source files exactly

- No transformations applied

- Purpose: traceability & recovery

**Tables**

- learner_raw

- opportunity_raw

- learner_opportunity_raw

- cohort_raw

- cognito_raw

- marketing_raw

### 🟡 Fixed Layer

- Data standardization and correction

- Deduplication

- Type casting

- Quality flags

**Examples**

- Deduplicated campaigns by spend & date

- Standardized campaign naming

- Validated learner profiles

**Tables**

- learner_fix

- opportunity_fix

- learner_opp_fix

- cohort_fix

- cognito_fix

- marketing_fix

### 🔵 Clean Layer

- Entity composition

- Conformed keys

- Controlled joins

- Analytics-safe defaults

**Tables**

- learner_cog_clean

- coh_and_learner_opp_clean

- opp_and_learner_opp_clean

- mark_opp_clean

### 🟢 Business Layer

- Read-only analytics views

- BI-optimized schema

- Derived metrics included

**Primary Views**

- master_marketing_analytics

- campaign_performance_mart

- marketing funnel

**Screenshot:**

![Data Flow Diagram](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Diagrams/Data%20Flow%20Diagram(learner_db).drawio.png)

---

## Master Analytics View
`master_marketing_analytics`

Grain: One row per `Learner × Opportunity × Campaign`

**Purpose**

- Single source of truth for dashboards

- Handles deduplication at analytics level

- Compatible with Looker Studio aggregations

**Includes**

- Learner demographics

- Opportunity & cohort context

- Marketing performance

- Derived KPIs (conversion rate, cost per conversion)

## Campaign Performance Mart
`campaign_performance_mart`

Grain: One row per `Campaign × Date`

**Purpose**

- Executive-level campaign reporting
- Performance trend analysis
- Cost and conversion efficiency tracking

## Marketing Funnel
`marketing funnel`

**Purpose**

- Represents funnel stages and values for dashboarding
- Enables visualization of:
  - Reach
  - Clicks
  - Results (conversions)

Due to Looker Studio limitations, funnel stages are modeled using structured metrics rather than a single multi-metric funnel object.

---

## Data Quality & Auditing

Quality checks are applied consistently across layers: 
- Duplicate detection and removal
- Null handling with business-safe defaults
- Invalid learner profile filtering
- Campaign ↔ opportunity matching flags
- Cost and result sanity checks

Only validated data is promoted forward at each layer.

---

## Dashboarding (Looker Studio)

- Connected via Google Sheets/ CSV export

- Numeric fields explicitly cast for BI compatibility
- Metrics pre-aggregated where required
- Funnel visualizations implemented using multiple charts

---

## Technologies Used

- PostgreSQL

- SQL (CTEs, window functions, regex, deduplication logic)

- Looker Studio

- CSV ingestion

- GitHub

---

## Repository Structure

├── sql/
│   ├── raw/
│   ├── fixed/
│   ├── clean/
│   └── business/
├── docs/
│   ├── scripts.sql
│   ├── data_flow_diagram.png
│   ├── layered_architecture.png
│   ├── data_dictionary_fix_and_clean.md
│   ├── data_dictionary_business_layer.md
│   └── sql_queries.sql
├── dashboards/
│   └── looker_wireframe.pdf
└── README.md

---
## Author

Built as an end-to-end analytics engineering project demonstrating:

- Data modeling and warehouse design

- SQL-based transformations

- Data quality enforcement

- BI-ready analytics views

- Dashboard enablement using Looker Studio
