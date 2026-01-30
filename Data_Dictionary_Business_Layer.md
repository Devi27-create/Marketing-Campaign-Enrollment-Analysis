# Data Dictionary – Business Layer
master_marketing_analytics

Grain: Learner × Opportunity × Campaign

**1️⃣ Learner Fields**
| Column      | Type | Description               |
| ----------- | ---- | ------------------------- |
| learner_key | INT  | Surrogate learner key     |
| learner_id  | TEXT | Source learner identifier |
| email       | TEXT | Learner email             |
| gender      | TEXT | Gender                    |
| age         | INT  | Calculated age            |
| city        | TEXT | City                      |
| state       | TEXT | State                     |
| country     | TEXT | Country                   |
| degree      | TEXT | Degree                    |
| institution | TEXT | Institution               |
| major       | TEXT | Major                     |

**2️⃣ Opportunity Fields**
| Column               | Type | Description      |
| -------------------- | ---- | ---------------- |
| opportunity_id       | TEXT | Opportunity ID   |
| opportunity_name     | TEXT | Opportunity name |
| opportunity_category | TEXT | Category         |
| opportunity_code     | TEXT | Internal code    |


**3️⃣ Enrollment Fields**
| Column            | Type | Description             |
| ----------------- | ---- | ----------------------- |
| enrollment_status | TEXT | Application status      |
| apply_date        | DATE | Application date        |
| learner_opp_flag  | TEXT | Enrollment quality flag |


**4️⃣ Cohort Fields**
| Column            | Type | Description     |
| ----------------- | ---- | --------------- |
| cohort_id         | TEXT | Cohort ID       |
| cohort_code       | TEXT | Cohort code     |
| cohort_size       | INT  | Size            |
| cohort_start_date | DATE | Start date      |
| cohort_end_date   | DATE | End date        |
| duration_days     | INT  | Duration        |
| cohort_status     | TEXT | Status          |
| cohort_size_flag  | TEXT | Size validation |


**5️⃣ Marketing Fieldss**
| Column                  | Type    | Description                      |
| ----------------------- | ------- | -------------------------------- |
| ad_account_name         | TEXT    | Ad account                       |
| campaign_name           | TEXT    | Campaign name                    |
| campaign_month          | TEXT    | Detected month                   |
| campaign_type           | TEXT    | Course / Event / Internship etc. |
| marketing_objective     | TEXT    | Awareness / Leads / Conversions  |
| delivery_status         | TEXT    | Delivery status                  |
| delivery_level          | TEXT    | Delivery granularity             |
| reach                   | INT     | Reach                            |
| outbound_clicks         | INT     | Clicks                           |
| results                 | INT     | Results                          |
| cost_per_result         | NUMERIC | Cost per result                  |
| amount_spent_aed        | NUMERIC | Spend                            |
| cpc_cost_per_link_click | NUMERIC | CPC                              |
| reporting_starts        | DATE    | Reporting date                   |
| performance_flag        | TEXT    | Cost/result quality              |
| marketing_match_flag    | TEXT    | Campaign ↔ Opportunity match     |


**6️⃣ Derived Metrics**
| Column                  | Type    | Description                      |
| ----------------------- | ------- | -------------------------------- |
| ad_account_name         | TEXT    | Ad account                       |
| campaign_name           | TEXT    | Campaign name                    |
| campaign_month          | TEXT    | Detected month                   |
| campaign_type           | TEXT    | Course / Event / Internship etc. |
| marketing_objective     | TEXT    | Awareness / Leads / Conversions  |
| delivery_status         | TEXT    | Delivery status                  |
| delivery_level          | TEXT    | Delivery granularity             |
| reach                   | INT     | Reach                            |
| outbound_clicks         | INT     | Clicks                           |
| results                 | INT     | Results                          |
| cost_per_result         | NUMERIC | Cost per result                  |
| amount_spent_aed        | NUMERIC | Spend                            |
| cpc_cost_per_link_click | NUMERIC | CPC                              |
| reporting_starts        | DATE    | Reporting date                   |
| performance_flag        | TEXT    | Cost/result quality              |
| marketing_match_flag    | TEXT    | Campaign ↔ Opportunity match     |

**7️⃣campaign_performance_mart**
Grain: Campaign × Reporting Date

| Column              | Type    | Description        |
| ------------------- | ------- | ------------------ |
| campaign_name       | TEXT    | Campaign           |
| campaign_type       | TEXT    | Type               |
| marketing_objective | TEXT    | Objective          |
| reporting_starts    | DATE    | Date               |
| total_reach         | INT     | Aggregated reach   |
| total_clicks        | INT     | Aggregated clicks  |
| total_results       | INT     | Aggregated results |
| total_spend         | NUMERIC | Total spend        |
| avg_cpc             | NUMERIC | Avg CPC            |
| conversion_rate     | NUMERIC | Results ÷ reach    |

**8️⃣Learner funnel**
| Column              | Type    | Description        |
| ------------------- | ------- | ------------------ |
|


