# Marketing Campaign & Enrollment Analytics Project

## Overview

This project implements an end-to-end analytics engineering pipeline to analyze the relationship between marketing campaigns, learner enrollments, opportunities, and cohorts.

Raw operational data is transformed through a layered data warehouse architecture into business-ready analytical views, which power an interactive Looker Studio dashboard for marketing and enrollment performance analysis.

The project demonstrates real-world analytics engineering practices including data modeling, quality enforcement, auditability, and BI-friendly design.


## Business Use Cases

- Measure marketing effectiveness from reach → conversions

- Attribute learner enrollments to marketing campaigns

- Analyze campaign efficiency by type, objective, and time

- Understand enrollment patterns across opportunities and cohorts

- Enable executive and analytical reporting in Looker Studio


## Layered Data Warehouse Architecture

This project follows a four-layer warehouse design to ensure data quality, scalability, and traceability.

### 🔹 Architecture Diagram

Raw → Fixed → Clean → Business → Consumption

**Architecture Summary**

**Raw Layer:** Source-aligned ingestion (no transformations)

**Fixed Layer:** Cleansing, standardization, deduplication, quality flags

**Clean Layer:** Entity composition with controlled joins

**Business Layer:** Analytics-ready views

**Consumption:** Looker Studio dashboards

**Architecture Principles**
- Full-load ingestion using CSV source files
- Truncate & insert strategy for Raw and Fixed layers
- Conformed entities created in Clean layer
- Business Layer exposes read-only master analytics views
- Consumption via Looker Studio dashboards

**Screenshot:**

![Layered Architecture](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Diagrams/Layered%20Data%20Warehouse%20Architecture%20(Raw%20%E2%86%92%20Fixed%20%E2%86%92%20Clean%20%E2%86%92%20Final)%20(Learner%20Dataset).drawio.png)


## 🔹 Data Flow Overview

Each dataset is independently validated and standardized before being joined, preventing data contamination and double counting.

**Key Principles**

- No joins in Raw or Fixed layers
- Quality flags applied before composition
- Business logic isolated from transformation logic
- BI tools consume views only, never transformation tables

## Source Datasets

- **Learner:** learner profiles and demographics

- **Opportunity:** programs, courses, events

- **Learner Opportunity:** enrollment and application records

- **Cohort:** cohort lifecycle and sizing

- **Cognito:** user identity and profile data

- **Marketing Campaign:** campaign performance metrics

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

- Deduplication using window functions

- Null handling and Type casting

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

### 🟢 Business Layer (Analytics View)

- Read-only analytics views

- BI-optimized schema

- Derived metrics included

**Analytic View:** 
`master_marketing_and_enrollment`

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

**Screenshot:**

![Data Flow Diagram](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Diagrams/Data%20Flow%20Diagram(learner_db).drawio.png)

## Dashboard (Looker Studio)

The analytics views power a multi-page Looker Studio dashboard.

**Dashboard Highlights**

- **Executive KPIs**
 - Total Spend
 - Total Conversions
 - Avg Cost per Conversion
 - Marketing Attribution %

- **Trends**
 - Spend vs Results over time
 - Conversion rate trends
 
- **Campaign Analysis**
 - Cost per result by campaign
 - Conversion rate by campaign
 - Spend vs results by campaign type

- **Funnel Analysis**
 - Reach → Clicks → Conversions
 - Modeled using separate charts due to Looker limitations

**Screenshot:**

![Dashboard](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Dashboard/Page%201.png)
![Dashboard](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Dashboard/Page%202.png)
![Dashboard](https://github.com/Devi27-create/Marketing-Campaign-Enrollment-Analysis/blob/main/Dashboard/Page%203.png)

## Data Quality & Auditing

Quality checks are applied consistently across layers: 
- Duplicate detection and removal
- Null handling with business-safe defaults
- Invalid learner profile filtering
- Campaign ↔ opportunity matching flags
- Cost and result sanity checks

Only validated records are promoted to analytics views.

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
|   ├── dashboard.pdf
│   ├── data_dictionary_fix_and_clean.md
│   └── data_dictionary_business_layer.md
├── dashboards/
│   └── looker_wireframe.pdf
└── README.md

---
## Author

Built as an end-to-end real world analytics engineering project demonstrating:

- Data modeling and warehouse design

- SQL-based transformations

- Data quality enforcement

- BI-ready analytics views

- Dashboard enablement using Looker Studio
