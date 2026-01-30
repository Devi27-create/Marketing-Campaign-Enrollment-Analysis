# Marketing Campaign Enrollment Analysis

## Overview

The Marketing Campaign Enrollment Analysis project is an end-to-end data engineering and analytics pipeline designed to consolidate, clean, enrich, and analyze marketing campaign performance alongside learner enrollment data.

The system transforms multiple raw operational datasets into structured, analytics-ready tables, enabling accurate campaign performance tracking, learner engagement analysis, and cohort-level insights.

This project emphasizes:
 
- Data quality enforcement
- Scalable transformations
- Auditable enrichment logic
- Analytics-ready dimensional modeling

## Architecture & Data Flow

The pipeline follows a layered data model:

     Raw
      ↓
     Fix
      ↓
    Clean
      ↓
Master Analytics
      ↓
  Dashboard


Each layer is designed to be:

- Rebuildable

- Auditable

- Isolated from downstream logic changes

## Datasets Used
### 1️⃣ Learner

Contains demographic and academic information for learners.

- Learner ID

- Country

- Degree

- Institution

- Major

Used to understand learner distribution, educational background, and profile completeness.

### 2️⃣ Opportunity

Captures details of programs, courses, challenges, and internships.

- Opportunity ID

- Opportunity Name

- Category

- Opportunity Code

- Tracking Questions

Supports campaign-to-opportunity attribution and enrollment analysis.

### 3️⃣ Learner Opportunity

- Represents enrollment activity.

- Enrollment ID

- Learner ID

- Assigned Cohort

- Application Date

- Enrollment Status

Tracks learner engagement across opportunities and campaigns.

### 4️⃣ Cohort

Defines structured learning groups.

- Cohort ID

- Cohort Code

- Start Date

- End Date

- Cohort Size

Used for time-based analysis, cohort lifecycle tracking, and capacity insights.

### 5️⃣  Cognito

User account and demographic data sourced from authentication systems.

- User ID

- Email

- Gender

- Birthdate

- Location (City, State, Zip)

- Account creation & modification timestamps

Enables user-level segmentation and demographic analysis.

### 6️⃣  Marketing Campaign

- Marketing performance metrics across platforms.

- Ad Account Name

- Campaign Name

- Delivery Status & Level

- Reach

- Clicks & Results

- Cost Metrics (CPC, Cost per Result, Spend)

- Reporting Start Date

Used to evaluate campaign effectiveness and ROI.

## Data Cleaning & Standardization

Raw datasets are transformed into fixed then clean tables using a PostgreSQL stored procedure:

### Key transformations include:

- Null and placeholder value normalization

- Text standardization (trimming, decoding, validation)

- Deduplication using window functions

- Derived attributes (age, cohort duration, campaign month)

- Data quality flags for auditing

All transformations are set-based, ensuring scalability and performance.

## Marketing Campaign Enrichment

Marketing campaigns are enriched with derived attributes:

- Campaign Month (non-positional keyword detection)

- Campaign Type (Competition, Internship, Course, etc.)

- Marketing Objective (Awareness, Prospecting, Leads, Reach)

- Performance Flags (high cost, no results, valid)

Campaign names are preserved in raw form to maintain traceability.

## Fuzzy Matching & Audit Layer

Due to inconsistent naming conventions between campaigns and opportunities, fuzzy matching is used to link them:

- PostgreSQL pg_trgm extension for similarity scoring

- Normalized comparison fields

- Best-match selection per campaign

- Confidence scoring (High / Medium / Low)

An audit table captures low-confidence matches for manual review, ensuring transparency and control.

## Automation

All fixed-layer transformations are orchestrated via a PostgreSQL stored procedure:

- Rebuilds all cleaned tables

- Logs execution time per dataset

- Fails safely with error reporting

This makes the pipeline reproducible and production-ready.

## Dashboard

The processed data feeds an analytics dashboard that provides insights into:

- Campaign performance

- Learner enrollment trends

- Opportunity engagement

- Cohort lifecycle analysis

## 📊 Dashboard Preview:

Dashboard screenshot: [Alt]()

## Tech Stack

- Database: PostgreSQL

- Data Modeling: Star-schema inspired fact & dimension design

- ETL: SQL / PL-pgSQL (set-based transformations)

- Text Matching: pg_trgm fuzzy matching

- Visualization: BI dashboard (PDF preview included)

## Key Takeaways

- Built with real-world data inconsistency in mind

- Emphasizes auditability over blind automation

- Designed to scale from analysis to production

- Clean separation between raw, fixed, and enriched layers
