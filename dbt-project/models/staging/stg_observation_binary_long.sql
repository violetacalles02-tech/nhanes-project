-- Ruta sugerida: models/staging/stg_observation_binary_long.sql
-- Fuentes: raw.smq_l, raw.alq_l, raw.paq_l, raw.mcq_l
--
-- Despivota las 4 variables binarias Si/No a formato largo, igual patron
-- que stg_mcq_l_long para condition_occurrence.

with smq as (
    select seqn::integer as person_id, 'SMQ020'::text as variable_name, smq020::integer as value
    from {{ source('raw', 'smq_l') }}
),

alq as (
    select seqn::integer as person_id, 'ALQ111'::text as variable_name, alq111::integer as value
    from {{ source('raw', 'alq_l') }}
),

paq as (
    select seqn::integer as person_id, 'PAQ650'::text as variable_name, paq650::integer as value
    from {{ source('raw', 'paq_l') }}
),

mcq as (
    select seqn::integer as person_id, 'MCQ300C'::text as variable_name, mcq300c::integer as value
    from {{ source('raw', 'mcq_l') }}
),

unioned as (

    select * from smq
    union all
    select * from alq
    union all
    select * from paq
    union all
    select * from mcq

)

select * from unioned
where value is not null
