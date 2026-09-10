-- Ruta sugerida: models/staging/stg_condition_occurrence_diabetes.sql
-- Fuente: raw.diq_l (cuestionario de diabetes)
--
-- DIQ010: "Le ha dicho un medico que tiene diabetes?"
--   1 = Si (Diabetes mellitus confirmada)
--   2 = No (se descarta, no genera fila)
--   3 = Borderline (Prediabetes)
--   7/9 = Refused/Don't know (se descarta)
--
-- concept_id verificados contra vocabularies.concept (domain_id = 'Condition',
-- standard_concept = 'S'): 201820 = Diabetes mellitus, 37018196 = Prediabetes.
--
-- condition_start_date imputada como el primer dia del ciclo (mismo
-- criterio que observation_period_start_date), ya que NHANES no da
-- fecha real del diagnostico.

with source as (

    select * from {{ source('raw', 'diq_l') }}

),

mapped as (

    select
        seqn::integer                                            as person_id,

        case diq010
            when 1 then 201820   -- Diabetes mellitus (verificado en vocabularies.concept)
            when 3 then 37018196 -- Prediabetes (verificado en vocabularies.concept)
        end::integer                                             as condition_concept_id,

        '2021-08-01'::date                                       as condition_start_date,
        null::date                                                as condition_end_date,
        45905770::integer                                        as condition_type_concept_id,  -- Patient Self-Reported Condition
        null::text                                                as stop_reason,
        null::integer                                             as provider_id,
        null::integer                                             as visit_occurrence_id,

        'DIQ010_' || diq010::text                                as condition_source_value,
        null::integer                                             as condition_source_concept_id

    from source
    where diq010 in (1, 3)

)

select * from mapped