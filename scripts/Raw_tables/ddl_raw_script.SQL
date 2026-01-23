/*
=========================================================================================
DDL Script: Create Raw Tables
=========================================================================================
Script Purpose:
    This script creates raw tables in the 'learner_db' database.
    Existing tables are dropped and recreated.
=========================================================================================
*/

-- =========================
-- Learner Raw
-- =========================

DROP TABLE IF EXISTS learner_raw CASCADE;
CREATE TABLE learner_raw (
	learner_id TEXT PRIMARY KEY,
    country TEXT,
    degree TEXT,
    institution TEXT,
    major TEXT
);

-- =========================
-- Opportunity Raw
-- =========================

DROP TABLE IF EXISTS opp_raw CASCADE;
CREATE TABLE opp_raw (
   	opportunity_id TEXT PRIMARY KEY,
    opportunity_name TEXT,
    category TEXT,
    opportunity_code TEXT,
    tracking_questions TEXT
);

-- =========================
-- Learner Opportunity Raw
-- =========================

DROP TABLE IF EXISTS learner_opp_raw CASCADE;
CREATE TABLE learner_opp_raw (
	enrollment_id TEXT,
    learner_id TEXT,
    assigned_cohort TEXT,
    apply_date TIMESTAMP,
    status INT
);


-- =========================
-- Cohort Raw
-- =========================

DROP TABLE IF EXISTS cohort_raw CASCADE;
CREATE TABLE cohort_raw (
    cohort_id TEXT,
    cohort_code TEXT PRIMARY KEY,
	start_date NUMERIC,
	end_date NUMERIC,
	size INT
);

-- =========================
-- Cognito Raw
-- =========================

DROP TABLE IF EXISTS cognito_raw CASCADE;
CREATE TABLE cognito_raw (
	user_id UUID PRIMARY KEY,
    email TEXT,
    gender TEXT,
    user_create_date TIMESTAMP,
    user_last_modified_date TIMESTAMP,
    birthdate DATE,
    city TEXT,
    zip TEXT,
    state TEXT
);


-- =========================
-- Marketing Raw
-- =========================

DROP TABLE IF EXISTS marketing_raw CASCADE;
CREATE TABLE marketing_raw (
	ad_account_name TEXT,
	campaign_name TEXT,
	delivery_status TEXT,
	delivery_level TEXT,
	reach BIGINT,
	outbound_clicks BIGINT,
	outbound_type BIGINT,
	result_type TEXT,
	results BIGINT,
	cost_per_result NUMERIC,
	amount_spent_aed NUMERIC,
	cpc_cost_per_link_click NUMERIC,
	reporting_starts DATE
);

