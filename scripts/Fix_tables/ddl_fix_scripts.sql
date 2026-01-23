/*
============================================================================================================================

============================================================================================================================


============================================================================================================================
*/
		
-----------------
-- Learner Fixed 
-----------------
		 
DROP TABLE IF EXISTS learner_fixed;

CREATE TABLE learner_fix AS
SELECT
    learner_id,

    COALESCE(NULLIF(TRIM(country), 'NULL'), 'Unknown') AS country,

    COALESCE(
        CASE
            WHEN degree IN (
                'Graduate Student',
                'Undergraduate Student',
                'High School Student',
                'Teacher/Educator',
                'Other Professional',
                'Not in Education'
            )
            THEN degree
            ELSE NULL
        END,
        'Unknown'
    ) AS degree,

    COALESCE(
        CASE
            WHEN UPPER(TRIM(institution)) = 'NULL' THEN NULL
            WHEN institution ~ '^[A-Za-z].{3,}$'
                 AND institution !~ '^[0-9]+$'
                 AND institution NOT IN ('.', '..', '...', '-', '----')
            THEN institution
            ELSE NULL
        END,
        'Unknown'
    ) AS institution,

    COALESCE(
        CASE
            WHEN UPPER(TRIM(major)) = 'NULL' THEN NULL
            WHEN major ~ '^[A-Za-z].{2,}$'
            THEN major
            ELSE NULL
        END,
        'Unknown'
    ) AS major,

    CASE
        WHEN
            COALESCE(
                CASE
                    WHEN degree IN (
                        'Graduate Student',
                        'Undergraduate Student',
                        'High School Student',
                        'Teacher/Educator',
                        'Other Professional',
                        'Not in Education'
                    )
                    THEN degree
                    ELSE NULL
                END,
                'Unknown'
            ) = 'Unknown'
        AND
            COALESCE(
                CASE
                    WHEN UPPER(TRIM(institution)) = 'NULL' THEN NULL
                    WHEN institution ~ '^[A-Za-z].{3,}$'
                         AND institution !~ '^[0-9]+$'
                         AND institution NOT IN ('.', '..', '...', '-', '----')
                    THEN institution
                    ELSE NULL
                END,
                'Unknown'
            ) = 'Unknown'
        THEN 'incomplete_profile'
        ELSE 'valid'
    END AS profile_flag

FROM learner_raw;

---------------------
-- Opportunity Fixed
---------------------

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


------------------------------
-- Learner Opportunity Fixed
-----------------------------
DROP TABLE If EXISTS learner_opp_fix;

CREATE TABLE learner_opp_fix AS
SELECT 
    enrollment_id AS learner_id,  -- Swapped: real learner
    learner_id AS opportunity_id,  -- Swapped: real opportunity
    assigned_cohort,
    apply_date::TIMESTAMP AS apply_date,
    status,
    CASE 
        WHEN enrollment_id LIKE 'Opportunity#%' THEN 'invalid_placeholder'  -- Flag 186 bad
        WHEN apply_date IS NULL THEN 'missing_date'
        ELSE 'valid'
    END AS quality_flag
FROM learner_opp_raw
WHERE enrollment_id LIKE 'Learner#%';  -- Drop 186 invalid


----------------
-- Cohort Fixed
----------------
		 
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


		 ---------------------------------------------------------
---->>>> Cognito Fixed (dedup emails, convert dates, add age flag) <<<<----
		 ---------------------------------------------------------
DROP TABLE IF EXISTS cognito_fix;

CREATE TABLE cognito_fix AS
WITH dedup AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY user_last_modified_date DESC) AS rn
    FROM cognito_raw
)
SELECT 
    'Learner#' || user_id::TEXT AS learner_id,		-- Swapped: real learner
    email,
    COALESCE(gender, 'Unknown') AS gender,
    user_create_date::TIMESTAMP AS user_create_date,
    user_last_modified_date::TIMESTAMP AS user_last_modified_date,
    birthdate,
    COALESCE(city, 'Unknown') AS city,
    COALESCE(zip, 'Unknown') AS zip,
    COALESCE(state, 'Unknown') AS state,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age,
    CASE 
        WHEN gender NOT IN ('Male', 'Female', 'Other') THEN 'invalid_gender'
        WHEN birthdate IS NULL THEN 'missing_birthdate'
        ELSE 'valid'
    END AS quality_flag
FROM dedup
WHERE rn = 1;
		
-------------------
-- Marketing Fixed
-------------------
		 
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

