CREATE OR REPLACE PROCEDURE learner_db_raw_dataset()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN

    -- =========================
    -- Opportunity Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading opportunity_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

    DROP TABLE IF EXISTS opportunity_raw CASCADE;
    CREATE TABLE opportunity_raw (
        opportunity_id TEXT PRIMARY KEY,
        opportunity_name TEXT,
        category TEXT,
        opportunity_code TEXT,
        tracking_questions TEXT
    );

    end_time := clock_timestamp();
    RAISE NOTICE 'opportunity_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    -- =========================
    -- Cohort Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading cohort_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

    DROP TABLE IF EXISTS cohort_raw CASCADE;
    CREATE TABLE cohort_raw (
        cohort_id TEXT,
        cohort_code TEXT PRIMARY KEY,
        start_date NUMERIC,
        end_date NUMERIC,
        size INT
    );

    end_time := clock_timestamp();
    RAISE NOTICE 'cohort_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    -- =========================
    -- Marketing Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading marketing_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

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

    end_time := clock_timestamp();
    RAISE NOTICE 'marketing_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    -- =========================
    -- Learner Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading learner_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

    DROP TABLE IF EXISTS learner_raw CASCADE;
    CREATE TABLE learner_raw (
        learner_id TEXT PRIMARY KEY,
        country TEXT,
        degree TEXT,
        institution TEXT,
        major TEXT
    );

    end_time := clock_timestamp();
    RAISE NOTICE 'learner_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    -- =========================
    -- Learner Opportunity Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading learner_opportunity_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

    DROP TABLE IF EXISTS learner_opportunity_raw CASCADE;
    CREATE TABLE learner_opportunity_raw (
        enrollment_id TEXT,
        learner_id TEXT,
        assigned_cohort TEXT,
        apply_date TIMESTAMP,
        status INT
    );

    end_time := clock_timestamp();
    RAISE NOTICE 'learner_opportunity_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    -- =========================
    -- Cognito Raw
    -- =========================
	
    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'Loading cognito_raw table';
    RAISE NOTICE '----------------------------------------------------------------------------------';

    start_time := clock_timestamp();

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

    end_time := clock_timestamp();
    RAISE NOTICE 'cognito_raw table loaded. Time taken: % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    RAISE NOTICE '----------------------------------------------------------------------------------';
    RAISE NOTICE 'All RAW tables loaded successfully';
    RAISE NOTICE '----------------------------------------------------------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred in learner_db_raw_dataset: %', SQLERRM;
END;
$$;
