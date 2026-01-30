/*
============================================================================================================================
DDL Script: Create Clean Layer Tables
============================================================================================================================
Purpose:
    Creates clean-layer tables by composing and standardizing data from fixed-layer sources.
    Existing clean tables are dropped and fully rebuilt.

Clean Layer Responsibilities:
    - Integrate related entities across sources
    - Apply standardization and quality rules
    - Preserve row-level grain (no aggregations)
    - Prepare canonical datasets for downstream master / business layers

Execution:
    Run this script to re-define and align the structure of all clean-layer tables.
============================================================================================================================
*/

-- =======================================
-- Learner & Cognito Clean
-- =======================================
DROP TABLE IF EXISTS learner_cog_clean;

CREATE TABLE learner_cog_clean AS
    SELECT
        Row_Number() OVER (ORDER BY l.learner_id) AS learner_key, 
		l.learner_id,

        -- Cognito attributes
        c.email,
        c.gender,
        c.birthdate,
        c.age,
        c.city,
        c.state,
        c.zip,
        c.user_create_date,
        c.user_last_modified_date,

        -- Learner attributes
        l.country,
        l.degree,
        l.institution,
        l.major,
        l.profile_flag
    FROM learner_fix l
    LEFT JOIN cognito_fix c
        ON l.learner_id = c.learner_id
    WHERE l.profile_flag = 'valid';

-- Indexes
CREATE UNIQUE INDEX idx_lcc_learner_id ON learner_cog_clean(learner_id);
CREATE INDEX idx_lcc_learner_key ON learner_cog_clean(learner_key);
CREATE INDEX idx_lcc_country ON learner_cog_clean(country);


-- =======================================
-- Cohort & Learner Opportunity Clean
-- =======================================

DROP TABLE IF EXISTS coh_and_learner_opp_clean;

CREATE TABLE coh_and_learner_opp_clean AS
    SELECT
        lof.learner_id,
        cf.cohort_id,
        cf.cohort_code,
        lof.assigned_cohort,
        cf.cohort_size,
        cf.start_date,
        cf.end_date,
        cf.duration_days,
        cf.status_flag,
        cf.size_flag,
        lof.quality_flag AS learner_opp_flag
    FROM learner_opp_fix lof
    LEFT JOIN cohort_fix cf
        ON lof.assigned_cohort = cf.cohort_code;

-- Indexes
CREATE INDEX idx_cloc_learner_id ON coh_and_learner_opp_clean(learner_id);
CREATE INDEX idx_cloc_cohort_code ON coh_and_learner_opp_clean(cohort_code);
CREATE INDEX idx_cloc_assigned_cohort ON coh_and_learner_opp_clean(assigned_cohort);


-- =======================================
-- Opportunity & Learner Opportunity Clean
-- =======================================

DROP TABLE IF EXISTS opp_and_learner_opp_clean;

CREATE TABLE opp_and_learner_opp_clean AS
    SELECT
        o.opportunity_id,
        o.opportunity_name,
        o.category,
        o.opportunity_code,
        o.tracking_questions,

        lof.learner_id,
        lof.status,
        lof.apply_date
    FROM learner_opp_fix lof
    LEFT JOIN opportunity_fix o
        ON lof.opportunity_id = o.opportunity_id;

-- Indexes
CREATE INDEX idx_oloc_opportunity_id ON opp_and_learner_opp_clean(opportunity_id);
CREATE INDEX idx_oloc_apply_date ON opp_and_learner_opp_clean(apply_date);


-- =======================================
-- Marketing & Opportunity Clean
-- =======================================

DROP TABLE IF EXISTS mark_opp_clean;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE mark_opp_clean AS
    SELECT
        COALESCE(mf.ad_account_name, 'Unknown') AS ad_account_name,
        COALESCE(mf.campaign_name, 'No_Match') AS campaign_name,
        COALESCE(mf.delivery_status, 'Unknown') AS delivery_status,
        COALESCE(mf.delivery_level, 'Unknown') AS delivery_level,
        COALESCE(mf.reach, 0) AS reach,
        COALESCE(mf.outbound_clicks, 0) AS outbound_clicks,
        COALESCE(mf.outbound_type, 0) AS outbound_type,
        COALESCE(mf.result_type, 'Unknown') AS result_type,
        COALESCE(mf.results, 0) AS results,
        COALESCE(mf.cost_per_result, 0) AS cost_per_result,
        COALESCE(mf.amount_spent_aed, 0) AS amount_spent_aed,
        COALESCE(mf.cpc_cost_per_link_click, 0) AS cpc_cost_per_link_click,
        mf.reporting_starts,
		COALESCE(mf.campaign_month, 'Unknown') AS campaign_month,
		COALESCE(mf.campaign_type, 'Unknown') AS campaign_type,
		COALESCE(mf.marketing_objective, 'Unknown') AS marketing_objective,
        COALESCE(mf.performance_flag, 'Unknown') AS performance_flag,
        o.opportunity_id,
        o.opportunity_name,
        CASE
            WHEN mf.campaign_name IS NOT NULL THEN 'matched'
            ELSE 'unmatched'
        END AS marketing_match_flag
    FROM opportunity_fix o
    LEFT JOIN marketing_fix mf
  	ON mf.campaign_name IS NOT NULL
 	AND o.opportunity_name IS NOT NULL
 	AND (
       o.opportunity_name ILIKE '%' || mf.campaign_name || '%'
    OR mf.campaign_name ILIKE '%' || o.opportunity_name || '%'
 )

-- Indexes
CREATE INDEX idx_moc_campaign_name ON mark_opp_clean(campaign_name);
CREATE INDEX idx_moc_match_flag ON mark_opp_clean(marketing_match_flag);
