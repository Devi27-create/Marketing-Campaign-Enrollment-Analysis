/*
============================================================================================================================
Stored Procedure: Load Fix layer (Raw -> Fix)
============================================================================================================================
Script Purpose:
	This stored procedure performs sthe ETL (Extract, Transform, Load) process to populate the Fix tables from the Raw 
	tables.
 Actions Performed:
	- Drop Fix tables.
	- Inserts transformed and cleansed data from Raw into Fix tables.

Parameter:
	None.
	This stores procedure does note accept any parameters or return any values.

Usage Example:
	EXEC Learner_DB_Fixed_Dataset;
============================================================================================================================
*/

CREATE OR REPLACE PROCEDURE Learner_DB_Fixed_Dataset()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN

    -- =========================
    -- Learner Fixed
    -- =========================
	
    start_time := clock_timestamp();

	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading learner_Fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS learner_fix;

	CREATE TABLE learner_fix AS
	SELECT
	    learner_id,
	    COALESCE(NULLIF(TRIM(country),'NULL'),'Unknown') AS country,
	    COALESCE(
	        CASE
	            WHEN degree IN (
	                'Graduate Student','Undergraduate Student','High School Student',
	                'Teacher/Educator','Other Professional','Not in Education'
	            ) THEN degree
	        END,'Unknown'
	    ) AS degree,
	    COALESCE(
	        CASE
	            WHEN UPPER(TRIM(institution)) = 'NULL' THEN NULL
	            WHEN institution ~ '^[A-Za-z].{3,}$'
	                 AND institution !~ '^[0-9]+$'
	                 AND institution NOT IN ('.','..','...','-','----')
	            THEN institution
	        END,'Unknown'
	    ) AS institution,
	    COALESCE(
	        CASE
	            WHEN UPPER(TRIM(major)) = 'NULL' THEN NULL
	            WHEN major ~ '^[A-Za-z].{2,}$' THEN major
	        END,'Unknown'
	    ) AS major,
	    CASE
	        WHEN degree = 'Unknown' AND institution = 'Unknown' THEN 'incomplete_profile'
	        ELSE 'valid'
	    END AS profile_flag
	FROM learner_raw;
	
	-- Indexes
	CREATE UNIQUE INDEX idx_learner_fix_id ON learner_fix(learner_id);
	CREATE INDEX idx_learner_fix_profile ON learner_fix(profile_flag);
	
	end_time := clock_timestamp();
	RAISE NOTICE 'learner_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
	
	-- =========================
    -- Opportunity Fixed
    -- =========================
	
   
    start_time := clock_timestamp();


	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading opportunity_fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS opportunity_fix;

	CREATE TABLE opportunity_fix AS
	SELECT 
	    opportunity_id,
	    TRIM(
	        REPLACE(REPLACE(opportunity_name, '%27', ''''), '+', '&') -- Fixed name's
	    ) AS opportunity_name,
	    category,
	    opportunity_code,
	    COALESCE(tracking_questions, 'None') AS tracking_questions	-- Handle 69 nulls
	FROM opportunity_raw
	WHERE opportunity_name IS NOT NULL;	-- Drop any fully null rows (none observed)

	-- Indexes
	CREATE INDEX idx_opp_fix_id ON opportunity_fix(opportunity_id);
	CREATE INDEX idx_opp_fix_name ON opportunity_fix(opportunity_name);
	
	end_time := clock_timestamp();
	RAISE NOTICE 'opportunity_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);


	-- =========================
    -- Learner Opportunity Fixed
    -- =========================

	start_time := clock_timestamp();
	

	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading learner_opportunity_fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS learner_opp_fix;

	CREATE TABLE learner_opp_fix AS
	SELECT 
	    enrollment_id AS learner_id,
	    learner_id AS opportunity_id,
	    assigned_cohort,
	    apply_date::TIMESTAMP AS apply_date,
	    status,
	    CASE 
	        WHEN enrollment_id LIKE 'Opportunity#%' THEN 'invalid_placeholder'
	        WHEN apply_date IS NULL THEN 'missing_date'
	        ELSE 'valid'
	    END AS quality_flag
	FROM learner_opportunity_raw
	WHERE enrollment_id LIKE 'Learner#%';

	-- Indexes
	CREATE INDEX idx_lo_fix_learner ON learner_opp_fix(learner_id);
	CREATE INDEX idx_lo_fix_opp ON learner_opp_fix(opportunity_id);
	CREATE INDEX idx_lo_fix_cohort ON learner_opp_fix(assigned_cohort);
	
	end_time := clock_timestamp();
	RAISE NOTICE 'learner_opp_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);


    -- =========================
    -- Cohort Fixed
    -- =========================
	
    start_time := clock_timestamp();

	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading cohort_fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS cohort_fix;

	CREATE TABLE cohort_fix AS
	SELECT 
	    cohort_id,
	    cohort_code,
	    TO_TIMESTAMP(start_date / 1000) AT TIME ZONE 'IST' AS start_date,
	    TO_TIMESTAMP(end_date / 1000) AT TIME ZONE 'IST' AS end_date,
	    size AS cohort_size,                           
	    EXTRACT(DAY FROM (
	        TO_TIMESTAMP(end_date / 1000) - 
	        TO_TIMESTAMP(start_date / 1000)
	    )) AS duration_days,
	    CASE
			WHEN TO_TIMESTAMP(start_date / 1000) > CURRENT_DATE THEN 'upcoming'
	        WHEN TO_TIMESTAMP(end_date / 1000) >= CURRENT_DATE THEN 'active'
	        WHEN TO_TIMESTAMP(end_date / 1000) < CURRENT_DATE THEN 'completed'
	        ELSE 'future_or_invalid'
	    END AS status_flag,
	    CASE 
	        WHEN size > 100000 THEN 'oversized'
	        WHEN size < 10 THEN 'undersized'
	        ELSE 'valid'
	    END AS size_flag
	FROM cohort_raw
	WHERE start_date <= end_date AND size > 0; -- Drop invalid (none observed)
	
	-- Indexes
	CREATE UNIQUE INDEX idx_cohort_fix_code ON cohort_fix(cohort_code);
	CREATE INDEX idx_cohort_fix_cohort_size ON cohort_fix(status_flag);
	
	end_time := clock_timestamp();
	RAISE NOTICE 'cohort_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);


	-- =========================
    -- Cognito Fixed
    -- =========================
	
    start_time := clock_timestamp();

	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading cognito fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS cognito_fix;

	CREATE TABLE cognito_fix AS
	WITH dedup AS (
	    SELECT *,
	           ROW_NUMBER() OVER (PARTITION BY email ORDER BY user_last_modified_date DESC) AS rn
	    FROM cognito_raw
	)
	SELECT 
	    user_id AS learner_id,
	    email,
	    COALESCE(gender, 'Unknown') AS gender,
	    user_create_date::TIMESTAMP,
	    user_last_modified_date::TIMESTAMP,
	    birthdate,
	    COALESCE(city, 'Unknown') AS city,
	    COALESCE(state, 'Unknown') AS state,
	    COALESCE(zip, 'Unknown') AS zip,
	    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age,
	    CASE 
	        WHEN gender NOT IN ('Male','Female','Other') THEN 'invalid_gender'
	        WHEN birthdate IS NULL THEN 'missing_birthdate'
	        ELSE 'valid'
	    END AS quality_flag
	FROM dedup
	WHERE rn = 1;

	-- Indexes
	CREATE UNIQUE INDEX idx_cognito_fix_learner ON cognito_fix(learner_id);
	CREATE INDEX idx_cognito_fix_email ON cognito_fix(email);
	
	end_time := clock_timestamp();
	RAISE NOTICE 'cognito_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
	

    -- =========================
    -- Marketing Fixed
    -- =========================
	
    start_time := clock_timestamp();

	RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading marketing_fixed table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

	DROP TABLE IF EXISTS marketing_fix;

	CREATE TABLE marketing_fix AS
	WITH dedup AS (
	    SELECT *,
	           ROW_NUMBER() OVER (
	               PARTITION BY campaign_name, reporting_starts
	               ORDER BY amount_spent_aed DESC
	           ) AS rn
	    FROM marketing_raw
	),
	
	campaign_fix AS (
	    SELECT
	        ad_account_name,
	        COALESCE(campaign_name, 'Unknown') AS campaign_name,
	        delivery_status,
	        delivery_level,
	        reach,
	        COALESCE(outbound_clicks, 0) AS outbound_clicks,
	        COALESCE(outbound_type, 0) AS outbound_type,
	        result_type,
	        results,
	        cost_per_result,
	        amount_spent_aed,
	        COALESCE(cpc_cost_per_link_click, 0) AS cpc_cost_per_link_click,
	        reporting_starts::DATE AS reporting_starts,
	
	        -- Month
	        CASE
	            WHEN campaign_name ILIKE '%jan%' THEN 'January'
	            WHEN campaign_name ILIKE '%feb%' THEN 'February'
	            WHEN campaign_name ILIKE '%mar%' THEN 'March'
	            WHEN campaign_name ILIKE '%apr%' THEN 'April'
	            WHEN campaign_name ILIKE '%may%' THEN 'May'
	            WHEN campaign_name ILIKE '%jun%' THEN 'June'
	            WHEN campaign_name ILIKE '%jul%' THEN 'July'
	            WHEN campaign_name ILIKE '%aug%' THEN 'August'
	            WHEN campaign_name ILIKE '%sept%' THEN 'September'
	            WHEN campaign_name ILIKE '%oct%' THEN 'October'
	            WHEN campaign_name ILIKE '%nov%' THEN 'November'
	            WHEN campaign_name ILIKE '%dec%' THEN 'December'
	            ELSE NULL
	        END AS campaign_month,
	
	        -- Campaign type
	        CASE
	            WHEN campaign_name ILIKE '%competition%' OR campaign_name ILIKE '%challenge%' THEN 'Competition'
	            WHEN campaign_name ILIKE '%internship%' THEN 'Internship'
	            WHEN campaign_name ILIKE '%masterclass%' THEN 'Masterclass'
	            WHEN campaign_name ILIKE '%course%' THEN 'Course'
	            WHEN campaign_name ILIKE '%workshop%' THEN 'Workshop'
	            WHEN campaign_name ILIKE '%event%' THEN 'Event'
	            ELSE 'Other'
	        END AS campaign_type,
	
	        -- Marketing objective
	        CASE
	            WHEN campaign_name ILIKE '%awareness%' THEN 'Awareness'
	            WHEN campaign_name ILIKE '%prospecting%' THEN 'Prospecting'
	            WHEN campaign_name ILIKE '%ads%' THEN 'Ads'
	            WHEN campaign_name ILIKE '%leads%' THEN 'Leads'
	            WHEN campaign_name ILIKE '%reach%' THEN 'Reach'
	            ELSE 'Other'
	        END AS marketing_objective,
	
	        -- Performance flag
	        CASE
	            WHEN cost_per_result > 10 THEN 'high_cost'
	            WHEN results = 0 THEN 'no_results'
	            ELSE 'valid'
	        END AS performance_flag
	
	    FROM dedup
	    WHERE rn = 1
	)
	
	SELECT *
	FROM campaign_fix;

	-- Indexes
	CREATE INDEX idx_marketing_fix_campaign ON marketing_fix(campaign_name);
	CREATE INDEX idx_marketing_fix_date ON marketing_fix(reporting_starts);
	CREATE INDEX idx_marketing_fix_camp_type ON marketing_fix(campaign_type);
	CREATE INDEX idx_marketing_fix_camp_month ON marketing_fix(campaign_month);

	
	end_time := clock_timestamp();
	RAISE NOTICE 'marketing_fix loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);
	
	RAISE NOTICE 'ALL FIXED TABLES LOADED SUCCESSFULLY';
	
	EXCEPTION
	WHEN OTHERS THEN
	    RAISE NOTICE 'ERROR in learner_db_fix_dataset: %', SQLERRM;
	END;
	$$;
