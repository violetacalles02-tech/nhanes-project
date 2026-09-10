with demo_l as (
 
    select * from {{ source('raw', 'demo_l') }}
 
),
 
mapped as (
 
    select
        d.seqn                           as person_id,
        '2021-08-31'::DATE               as observation_period_start_date,
        '2023-08-31'::DATE               as observation_period_end_date,
        NULL::INTEGER                    as period_type_concept_id  
 
    from demo_l d
 
)
 
select * from mapped
 