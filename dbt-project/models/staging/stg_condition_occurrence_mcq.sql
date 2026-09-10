-- Ruta sugerida: models/staging/stg_condition_occurrence_mcq.sql
-- Fuente: stg_mcq_l_long (formato largo) + seed nhanes_mcq_condition_mapping
--
-- Equivalente al patron del documento de referencia (join contra un
-- source_to_concept_map), adaptado a tablas anchas: primero se despivota
-- en stg_mcq_l_long, y aqui se une contra el seed de mapeo filtrando
-- value = 1 (Yes, "me han dicho que tengo esta condicion").

with unpivoted as (

    select * from {{ ref('stg_mcq_l_long') }}

),

mapping as (

    select * from {{ ref('nhanes_mcq_condition_mapping') }}

),

mapped as (

    select
        u.person_id                                              as person_id,
        m.condition_concept_id::integer                          as condition_concept_id,
        '2021-08-01'::date                                       as condition_start_date,
        null::date                                                as condition_end_date,
        45905770::integer                                        as condition_type_concept_id,  -- Patient Self-Reported Condition
        null::text                                                as stop_reason,
        null::integer                                             as provider_id,
        null::integer                                             as visit_occurrence_id,

        u.variable_name || '_' || u.value::text                  as condition_source_value,
        null::integer                                             as condition_source_concept_id

    from unpivoted as u
    inner join mapping as m
        on upper(u.variable_name) = upper(m.variable_name)
    where u.value = 1

)

select * from mapped