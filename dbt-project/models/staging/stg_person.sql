-- stg_person

{{
    config(
        materialized="table",
    )
}}


WITH demo_l AS (
    SELECT  *
    FROM {{ source('raw', 'demo_l') }}
),


person AS (
SELECT 
    d.seqn AS person_id, 
    case d.RIAGENDR when 1 then 8507 when 2 then 8532 when null then 8551 end as gender_concept_id,
    (2022 - d.ridageyr)::INTEGER AS year_of_birth,
    NULL::INTEGER AS month_of_birth, 
    NULL::INTEGER AS day_of_birth, 
    NULL::TIMESTAMP AS birth_datetime, 
    case d.RIDRETH1 when 3 then 8527 when 4 then 8516 when 5 then 8522 else 0 end as race_concept_ID,
    case d.RIDRETH1 when 1 then 38003563 when 2 then 38003564 else 0 end as ethnicity_concept_ID,
    NULL::INTEGER AS location_id, 
    NULL::INTEGER AS provider_id, 
    NULL::INTEGER AS care_site_id, 
    d.seqn::TEXT AS person_source_value, 
    d.RIAGENDR::TEXT AS gender_source_value, 
    NULL::INTEGER AS gender_source_concept_id, 
    d.RIDRETH1::TEXT AS race_source_value, 
    0::INTEGER AS race_source_concept_id, 
    d.RIDRETH1::TEXT AS ethnicity_source_value, 
    0::INTEGER AS ethnicity_source_concept_id 
FROM demo_l d 
)

SELECT * FROM person
