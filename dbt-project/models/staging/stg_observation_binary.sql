-- Ruta sugerida: models/staging/stg_observation_binary.sql
-- Fuente: stg_observation_binary_long + seed nhanes_observation_binary_mapping
--
-- Mismo patron que stg_condition_occurrence_mcq: solo se genera fila
-- cuando la respuesta es "Si" (value = 1); "No"/"No sabe" no generan
-- registro (ausencia = no reportado, practica habitual en OMOP).

with unpivoted as (

    select * from {{ ref('stg_observation_binary_long') }}

),

mapping as (

    select * from {{ ref('nhanes_observation_binary_mapping') }}

),

mapped as (

    select
        u.person_id                                              as person_id,
        m.observation_concept_id::integer                        as observation_concept_id,
        '2021-08-01'::date                                       as observation_date,
        null::timestamp                                          as observation_datetime,
        45905771::integer                                        as observation_type_concept_id,  -- Observation Recorded from a Survey
        null::numeric                                              as value_as_number,
        null::text                                                as value_as_string,
        null::integer                                              as value_as_concept_id,
        null::integer                                              as qualifier_concept_id,
        null::integer                                              as unit_concept_id,
        null::integer                                              as provider_id,
        null::integer                                              as visit_occurrence_id,
        null::integer                                              as visit_detail_id,

        u.variable_name || '_' || u.value::text                  as observation_source_value,
        null::integer                                              as observation_source_concept_id,
        null::text                                                as unit_source_value,
        null::text                                                as qualifier_source_value

    from unpivoted as u
    inner join mapping as m
        on upper(u.variable_name) = upper(m.variable_name)
    where u.value = 1

)

select * from mapped
