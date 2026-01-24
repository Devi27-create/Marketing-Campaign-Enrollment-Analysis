## Data Dictionary

### Marketing Campaign Enrollment Analysis

---
#### Data Model Overview

This project follows a two-stage transformation approach:

### 1️⃣ Fixed Layer (Standardization Layer)

- Cleans raw data

- Handles nulls, invalid values, encoding issues

- Deduplicates records

- Adds quality flags

- No business joins

### 2️⃣ Cleaned Layer (Analytics Layer)

- Combines fixed tables

- Applies business logic

- Produces analysis-ready datasets

- Optimized for dashboards & reporting

--- 

## FIXED LAYER TABLES

**1️⃣ learner_fix**

Cleaned and standardized learner profile data.

| Column Name    | Data Type | Description                                                            |
| -------------- | --------- | ---------------------------------------------------------------------- |
| `learner_id`   | TEXT      | Unique identifier for each learner                                     |
| `country`      | TEXT      | Learner’s country of residence (normalized, nulls mapped to `Unknown`) |
| `degree`       | TEXT      | Education level (validated against known values)                       |
| `institution`  | TEXT      | Educational institution name (validated text)                          |
| `major`        | TEXT      | Learner’s field of study                                               |
| `profile_flag` | TEXT      | Data quality flag (`valid`, `incomplete_profile`)                      |


**2️⃣ opportunity_fix**

Cleaned opportunity metadata.

| Column Name          | Data Type | Description                                     |
| -------------------- | --------- | ----------------------------------------------- |
| `opportunity_id`     | TEXT      | Unique identifier for opportunity               |
| `opportunity_name`   | TEXT      | Cleaned and decoded opportunity name            |
| `category`           | TEXT      | Opportunity category                            |
| `opportunity_code`   | TEXT      | Short code for referencing opportunities        |
| `tracking_questions` | TEXT      | Tracking questions (nulls replaced with `None`) |


**3️⃣ learner_opp_fix**

Validated learner enrollment records.

| Column Name       | Data Type | Description                       |
| ----------------- | --------- | --------------------------------- |
| `learner_id`      | TEXT      | Learner identifier                |
| `opportunity_id`  | TEXT      | Opportunity identifier            |
| `assigned_cohort` | TEXT      | Cohort assigned to learner        |
| `apply_date`      | TIMESTAMP | Application date                  |
| `status`          | TEXT      | Enrollment status                 |
| `quality_flag`    | TEXT      | Enrollment data quality indicator |


**4️⃣ cohort_fix**

Cohort lifecycle and size metadata.

| Column Name       | Data Type | Description                       |
| ----------------- | --------- | --------------------------------- |
| `learner_id`      | TEXT      | Learner identifier                |
| `opportunity_id`  | TEXT      | Opportunity identifier            |
| `assigned_cohort` | TEXT      | Cohort assigned to learner        |
| `apply_date`      | TIMESTAMP | Application date                  |
| `status`          | TEXT      | Enrollment status                 |
| `quality_flag`    | TEXT      | Enrollment data quality indicator |


**5️⃣ cognito_fix**

Deduplicated learner authentication and demographic data.

| Column Name     | Data Type | Description                                          |
| --------------- | --------- | ---------------------------------------------------- |
| `cohort_id`     | TEXT      | Unique cohort identifier                             |
| `cohort_code`   | TEXT      | Human-readable cohort code                           |
| `start_date`    | TIMESTAMP | Cohort start date                                    |
| `end_date`      | TIMESTAMP | Cohort end date                                      |
| `cohort_size`   | INTEGER   | Number of learners in cohort                         |
| `duration_days` | INTEGER   | Cohort duration in days                              |
| `status_flag`   | TEXT      | Cohort status (`upcoming`, `active`, `completed`)    |
| `size_flag`     | TEXT      | Size validation (`valid`, `oversized`, `undersized`) |


**6️⃣ marketing_fix**

Cleaned and enriched marketing campaign performance data.

| Column Name               | Data Type | Description                                   |
| ------------------------- | --------- | --------------------------------------------- |
| `ad_account_name`         | TEXT      | Advertising account name                      |
| `campaign_name`           | TEXT      | Campaign name (raw preserved)                 |
| `delivery_status`         | TEXT      | Campaign delivery status                      |
| `delivery_level`          | TEXT      | Delivery level                                |
| `reach`                   | INTEGER   | Total audience reached                        |
| `outbound_clicks`         | INTEGER   | Number of outbound clicks                     |
| `outbound_type`           | INTEGER   | Outbound click type                           |
| `result_type`             | TEXT      | Type of campaign result                       |
| `results`                 | INTEGER   | Number of results                             |
| `cost_per_result`         | NUMERIC   | Cost per result                               |
| `amount_spent_aed`        | NUMERIC   | Total spend (AED)                             |
| `cpc_cost_per_link_click` | NUMERIC   | Cost per click                                |
| `reporting_starts`        | DATE      | Reporting start date                          |
| `campaign_month`          | TEXT      | Derived campaign month                        |
| `campaign_type`           | TEXT      | Campaign category (Competition, Course, etc.) |
| `marketing_objective`     | TEXT      | Objective (Awareness, Leads, Reach, etc.)     |
| `performance_flag`        | TEXT      | Performance quality indicator                 |



---
## CLEANED LAYER TABLES

These are built by joining fixed tables for analytics use cases

**7️⃣ learner_cog_clean**

Unified learner profile combining learner attributes and Cognito demographics.

| Column                  | Data Type| Description                |
| ----------------------- | -------- |--------------------------- |
| learner_key             |          |Surrogate key               |
| learner_id              |          | Unique learner identifier  |
| email                   |          |Learner email               |
| gender                  |          |Gender                      |
| birthdate               |          |Date of birth               |
| age                     |          |Derived age                 |
| city                    |          |City                        |
| state                   |          |State                       |
| zip                     |          |ZIP code                    |
| user_create_date        |          |Account creation timestamp  |
| user_last_modified_date |          |Last modification timestamp |
| country                 |          |Country                     |
| degree                  |          |Education level             |
| institution             |          |Institution name            |
| major                   |          |Major                       |
| profile_flag            |          |Profile quality status      |



**8️⃣ cohort_and_learner_opp_clean**

Enrollment data enriched with cohort metadata.

| Column           | Data Type| Description                |
| ---------------- | -------- | -------------------------- |
| learner_id       |          | Learner ID                |
| cohort_id        |          | Cohort ID                 |
| cohort_code      |          | Cohort code               |
| assigned_cohort  |          | Assigned cohort reference |
| cohort_size      |          | Number of learners        |
| start_date       |          | Cohort start date         |
| end_date         |          | Cohort end date           |
| duration_days    |          | Duration in days          |
| status_flag      |          | Cohort status             |
| size_flag        |          | Size validation flag      |
| learner_opp_flag |          | Enrollment quality flag   |


**9️⃣ opp_and_learner_opp_clean**

Opportunity details linked to learner enrollments.

| Column             | Description              |
| ------------------ | ------------------------ |
| opportunity_id     | Opportunity ID           |
| opportunity_name   | Opportunity name         |
| category           | Opportunity category     |
| opportunity_code   | Reference code           |
| tracking_questions | Tracking metadata        |
| opp_flag           | Opportunity quality flag |
| learner_id         | Learner ID               |
| status             | Enrollment status        |
| apply_date         | Application date         |


**1️⃣0️⃣ mark_opp_clean**

Fuzzy-matched marketing campaigns to opportunities.

| Column                  | Description              |
| ----------------------- | ------------------------ |
| ad_account_name         | Ad account               |
| campaign_name           | Marketing campaign       |
| delivery_status         | Delivery status          |
| delivery_level          | Delivery level           |
| reach                   | Reach                    |
| outbound_clicks         | Outbound clicks          |
| outbound_type           | Outbound type            |
| result_type             | Result type              |
| results                 | Results                  |
| cost_per_result         | Cost per result          |
| amount_spent_aed        | Spend (AED)              |
| cpc_cost_per_link_click | CPC                      |
| reporting_starts        | Reporting date           |
| performance_flag        | Performance status       |
| opportunity_id          | Matched opportunity      |
| opportunity_name        | Matched opportunity name |
| marketing_match_flag    | `matched` / `unmatched`  |



## Notes

- All _fix tables represent analytics-ready datasets

- Raw tables remain unchanged for traceability

- Quality flags allow downstream filtering without data loss

- Designed for BI tools, reporting, and ML-ready analysis
