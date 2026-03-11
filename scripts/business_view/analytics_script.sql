/*
============================================================================================================================
DDL Script: Create Business Layer Tables
============================================================================================================================
Purpose:
    The business layer provides analytics-ready datasets derived from the clean layer.
    It applies business rules, aggregations, and calculations to support reporting,
    dashboards, and data-driven decision making.

Responsibilities:
    - Aggregate transactional data into meaningful business metrics
    - Apply business rules and derived calculations
    - Provide simplified datasets optimized for reporting and BI tools

Data Flow:
    Raw Layer  →  Fixed Layer →  Clean Layer  →  Business Layer
============================================================================================================================
*/

DROP VIEW IF EXISTS master_marketing_and_enrollment;

CREATE VIEW master_marketing_and_enrollment AS
WITH ranked AS (
    SELECT
        -- ======================
        -- Learner Dimension
        -- ======================
        lc.learner_key,
        lc.learner_id,
        lc.email,
        COALESCE(lc.gender, 'Unknown') AS gender,
        lc.age::INT AS age,
        COALESCE(lc.city, 'Unknown') AS city,
        COALESCE(lc.state, 'Unknown') AS state,
        COALESCE(lc.country, 'Unknown') AS country,
        COALESCE(lc.degree, 'Unknown') AS degree,
        COALESCE(lc.institution, 'Unknown') AS institution,
        COALESCE(lc.major, 'Unknown') AS major,
		

        -- ======================
        -- Opportunity Dimension
        -- ======================
        ol.opportunity_id,
        COALESCE(ol.opportunity_name, 'Unknown') AS opportunity_name,
        COALESCE(ol.category, 'Unknown') AS opportunity_category,
        COALESCE(ol.opportunity_code, 'Unknown') AS opportunity_code,

        -- ======================
        -- Enrollment Facts
        -- ======================
        ol.status::INT AS enrollment_status,
        ol.apply_date::DATE AS apply_date,
        clo.learner_opp_flag,

        -- ======================
        -- Cohort Dimension
        -- ======================
        clo.cohort_id,
        COALESCE(clo.cohort_code, 'Unknown') AS cohort_code,
        clo.cohort_size::INT AS cohort_size,
        clo.start_date::DATE AS cohort_start_date,
        clo.end_date::DATE AS cohort_end_date,
        clo.duration_days::INT AS cohort_duration_days,
        COALESCE(clo.status_flag, 'Unknown') AS cohort_status,
        COALESCE(clo.size_flag, 'Unknown') AS cohort_size_flag,

        -- ======================
        -- Marketing Dimension
        -- ======================
        COALESCE(mo.ad_account_name, 'Unknown') AS ad_account_name,
        COALESCE(mo.campaign_name, 'Unknown') AS campaign_name,
        COALESCE(mo.campaign_month, 'Unknown') AS campaign_month,
        COALESCE(mo.campaign_type, 'Unknown') AS campaign_type,
        COALESCE(mo.marketing_objective, 'Unknown') AS marketing_objective,
        COALESCE(mo.delivery_status, 'Unknown') AS delivery_status,
        COALESCE(mo.delivery_level, 'Unknown') AS delivery_level,

        -- ======================
        -- Marketing Facts
        -- ======================
        COALESCE(mo.reach, 0)::BIGINT AS reach,
        COALESCE(mo.outbound_clicks, 0)::BIGINT AS outbound_clicks,
        COALESCE(mo.results, 0)::BIGINT AS results,
        COALESCE(mo.cost_per_result, 0)::NUMERIC(12,2) AS cost_per_result,
        COALESCE(mo.amount_spent_aed, 0)::NUMERIC(14,2) AS amount_spent_aed,
        COALESCE(mo.cpc_cost_per_link_click, 0)::NUMERIC(12,2) AS cpc_cost_per_link_click,
        mo.reporting_starts::DATE AS reporting_starts,
        mo.performance_flag,
        mo.marketing_match_flag,

        -- ======================
        -- Join Flags
        -- ======================
        CASE
            WHEN ol.opportunity_id IS NULL THEN 'No_Opportunity'
            ELSE 'Has_Opportunity'
        END AS opportunity_join_status,

        CASE
            WHEN clo.cohort_id IS NULL THEN 'No_Cohort'
            ELSE 'Has_Cohort'
        END AS cohort_join_status,

        CASE
            WHEN mo.opportunity_id IS NULL THEN 'NO_MARKETING'
            ELSE 'Has_Mar'
        END AS marketing_join_status,

        -- ======================
        -- Derived Metrics
        -- ======================
        CASE
            WHEN mo.amount_spent_aed > 0 AND mo.results > 0
            THEN ROUND(mo.amount_spent_aed / mo.results, 2)
            ELSE 0
        END::NUMERIC(12,2) AS derived_cost_per_conversion,

        CASE
            WHEN mo.reach > 0
            THEN ROUND((mo.results::NUMERIC / mo.reach) * 100, 2)
            ELSE 0
        END::NUMERIC(6,2) AS conversion_rate_pct,

        -- ======================
        -- De-duplication logic
        -- ======================
        ROW_NUMBER() OVER (
            PARTITION BY
                lc.learner_id,
                ol.opportunity_id,
                COALESCE(mo.campaign_name, 'UNKNOWN')
            ORDER BY
                mo.reporting_starts DESC NULLS LAST,
                mo.amount_spent_aed DESC
        ) AS rn

    FROM learner_cog_clean lc

    LEFT JOIN opp_and_learner_opp_clean ol
        ON lc.learner_id = ol.learner_id

    LEFT JOIN coh_and_learner_opp_clean clo
        ON lc.learner_id = clo.learner_id

    LEFT JOIN mark_opp_clean mo
        ON ol.opportunity_id = mo.opportunity_id
)

SELECT *
FROM ranked
WHERE rn = 1;
