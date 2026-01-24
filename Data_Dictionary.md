## Data Dictionary

### Marketing Campaign Enrollment Analysis

**1️⃣ learner_fix**

Cleaned and standardized learner profile data.

#### Column_ Name	  Data_Type	  Description
     learner_id	   TEXT	      Unique identifier for each learner
     country	        TEXT	      Learner’s country of residence (normalized, nulls mapped to Unknown)
     degree	        TEXT	      Education level (validated against known values)
     institution	   TEXT	      Educational institution name (validated text)
     major	        TEXT	      Learner’s field of study
     profile_flag	   TEXT	      Data quality flag (valid, incomplete_profile)

**2️⃣ opportunity_fix**

Cleaned opportunity metadata.

#### Column_ Name	       Data_Type	  Description
     opportunity_id	       TEXT	       Unique identifier for opportunity
     opportunity_name	  TEXT	       Cleaned and decoded opportunity name
     category	            TEXT	       Opportunity category
     opportunity_code	  TEXT	       Short code for referencing opportunities
     tracking_questions	  TEXT 	       Tracking questions (nulls replaced with None)

**3️⃣ learner_opp_fix**

Validated learner enrollment records.

#### Column_ Name	      Data_Type	 Description
     learner_id	      TEXT	      Learner identifier
     opportunity_id	      TEXT	      Opportunity identifier
      assigned_cohort	 TEXT	      Cohort assigned to learner
      apply_date	      TIMESTAMP  	 Application date
      status	           TEXT	      Enrollment status
      quality_flag	      TEXT	      Enrollment data quality indicator

**4️⃣ cohort_fix**

Cohort lifecycle and size metadata.

#### Column_ Name	    Data_Type	    Description
     cohort_id	         TEXT	         Unique cohort identifier
     cohort_code	    TEXT	         Human-readable cohort code
     start_date	    TIMESTAMP	    Cohort start date
     end_date	         TIMESTAMP	    Cohort end date
     cohort_size	    INTEGER	    Number of learners in cohort
     duration_days	    INTEGER	    Cohort duration in days
     status_flag	    TEXT	         Cohort status (upcoming, active, completed)
     size_flag	         TEXT	         Size validation (valid, oversized, undersized)

**5️⃣ cognito_fix**

Deduplicated learner authentication and demographic data.

#### Column_ Name	          Data_Type	       Description
     learner_id	          TEXT	            Cognito user ID
     email	               TEXT     	       User email address
     gender	               TEXT	            Gender (normalized)
     user_create_date         TIMESTAMP	       Account creation timestamp
     user_last_modified_date	TIMESTAMP	       Last profile update
     birthdate	               DATE	            Date of birth
     city	                    TEXT	            City of residence
     state	               TEXT             State of residence
     zip	                    TEXT	            Zip / postal code
     age	                    INTEGER	       Derived age
     quality_flag	          TEXT          	  Data validation flag

**6️⃣ marketing_fix**

Cleaned and enriched marketing campaign performance data.

#### Column_ Name	          Data_Type	     Description
     ad_account_name	     TEXT	          Advertising account name
     campaign_name	          TEXT	          Campaign name (raw preserved)
     delivery_status	     TEXT	          Campaign delivery status
     delivery_level	          TEXT          	Delivery level
     reach	               INTEGER	     Total audience reached
     outbound_clicks	     INTEGER	     Number of outbound clicks
     outbound_type	          INTEGER	     Outbound click type
     result_type	          TEXT	          Type of campaign result
     results	               INTEGER	     Number of results
     cost_per_result	     NUMERIC	     Cost per result
     amount_spent_aed	     NUMERIC	     Total spend (AED)
     cpc_cost_per_link_click	NUMERIC	     Cost per click
     reporting_starts	     DATE          	Reporting start date
     campaign_month	          TEXT          	Derived campaign month
     campaign_type	          TEXT	          Campaign category (Competition, Course, etc.)
     marketing_objective	     TEXT	          Objective (Awareness, Leads, Reach, etc.)
     performance_flag	     TEXT          	Performance quality indicator

**7️⃣ Audit & Quality Flags (Conceptual)**

Used across tables to track data reliability.

#### Flag	                   Meaning
     valid	              Record meets all quality checks
     incomplete_profile	    Missing key learner attributes
     missing_date	         Required date field missing
     invalid_placeholder	    Placeholder IDs detected
     high_cost	              Cost per result exceeds threshold
     no_results	         Campaign produced zero results

## Notes

- All _fix tables represent analytics-ready datasets

- Raw tables remain unchanged for traceability

- Quality flags allow downstream filtering without data loss

- Designed for BI tools, reporting, and ML-ready analysis
