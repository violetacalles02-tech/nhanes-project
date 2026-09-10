-- Ruta sugerida: models/staging/stg_observation_health_status.sql
-- Fuente: raw.huq_l
--
-- HUQ010 es una escala ordinal 1-5 (Excellent...Poor), no Si/No, asi que
-- no encaja en el patron de stg_observation_binary. Se guarda el codigo
-- ordinal directamente en value_as_number en vez de mapear cada nivel a
-- un concept_id de respuesta (simplificacion documentada: un tribunal
-- podria preguntar por que no se mapeo cada nivel, la respuesta es que
-- se prioriza cobertura sobre granularidad en este ejercicio).

with source as (

    select * from {{ source('raw', 'huq_l') }}

),

mapped as (

    select
        seqn::integer                                             as person_id,
        4247398::integer                                          as observation_concept_id,  -- Health status
        '2021-08-01'::date                                        as observation_date,
        null::timestamp                                           as observation_datetime,
        45905771::integer                                         as observation_type_concept_id,  -- Observation Recorded from a Survey
        huq010::numeric                                            as value_as_number,
        null::text                                                 as value_as_string,
        null::integer                                               as value_as_concept_id,
        null::integer                                               as qualifier_concept_id,
        null::integer                                               as unit_concept_id,
        null::integer                                               as provider_id,
        null::integer                                               as visit_occurrence_id,
        null::integer                                               as visit_detail_id,

        'HUQ010'::text                                             as observation_source_value,
        null::integer                                               as observation_source_concept_id,
        null::text                                                 as unit_source_value,
        null::text                                                 as qualifier_source_value

    from source
    where huq010 is not null

)

select * from mapped
