-- Ruta sugerida: models/staging/stg_measurement.sql
-- Fuentes: raw.glu_l, raw.ghb_l, raw.hdl_l, raw.ins_l
--
-- Nucleo curado de MEASUREMENT (4 analitos centrales para diabetes), todos
-- los concept_id verificados contra vocabularies.concept por concept_code
-- exacto (LOINC) o concept_code UCUM exacto, no por busqueda de texto:
--   LBXGLU (glucosa en ayunas)  -> 3037110 (LOINC 1558-6),  unidad 8840  (mg/dL)
--   LBXGH  (HbA1c)              -> 3004410 (LOINC 4548-4),  unidad 8554  (%)
--   LBDHDD (colesterol HDL)     -> 3007070 (LOINC 2085-9),  unidad 8840  (mg/dL)
--   LBXIN  (insulina)           -> 3016244 (LOINC 20448-7), unidad 9093  (uIU/mL)
-- measurement_type_concept_id = 44818702 "Lab result" (verificado) --
-- a diferencia de condition_occurrence, estas NO son autoinformadas, son
-- mediciones reales tomadas en el examen fisico/laboratorio de NHANES.
--
-- measurement_date imputada como el primer dia del ciclo (mismo criterio
-- que el resto de fechas del proyecto), ya que NHANES no da fecha real.
-- measurement_id se genera con ROW_NUMBER() ya que no hay clave natural
-- (una persona puede tener varias mediciones).

with glucose as (

    select
        seqn::integer          as person_id,
        lbxglu::numeric         as value_as_number
    from {{ source('raw', 'glu_l') }}
    where lbxglu is not null

),

hba1c as (

    select
        seqn::integer          as person_id,
        lbxgh::numeric          as value_as_number
    from {{ source('raw', 'ghb_l') }}
    where lbxgh is not null

),

hdl as (

    select
        seqn::integer          as person_id,
        lbdhdd::numeric         as value_as_number
    from {{ source('raw', 'hdl_l') }}
    where lbdhdd is not null

),

insulin as (

    select
        seqn::integer          as person_id,
        lbxin::numeric          as value_as_number
    from {{ source('raw', 'ins_l') }}
    where lbxin is not null

),

unioned as (

    select person_id, 3037110::integer as measurement_concept_id, value_as_number, 8840::integer as unit_concept_id, 'LBXGLU'::text as measurement_source_value from glucose
    union all
    select person_id, 3004410::integer,                             value_as_number, 8554::integer,                   'LBXGH'::text                                  from hba1c
    union all
    select person_id, 3007070::integer,                             value_as_number, 8840::integer,                   'LBDHDD'::text                                 from hdl
    union all
    select person_id, 3016244::integer,                             value_as_number, 9093::integer,                   'LBXIN'::text                                  from insulin

),

mapped as (

    select
        row_number() over (order by person_id, measurement_concept_id)::integer as measurement_id,
        person_id                                               as person_id,
        measurement_concept_id                                  as measurement_concept_id,
        '2021-08-01'::date                                      as measurement_date,
        null::timestamp                                         as measurement_datetime,
        null::text                                               as measurement_time,
        44818702::integer                                       as measurement_type_concept_id,  -- Lab result
        null::integer                                            as operator_concept_id,
        value_as_number                                          as value_as_number,
        null::integer                                            as value_as_concept_id,
        unit_concept_id                                          as unit_concept_id,
        null::numeric                                            as range_low,
        null::numeric                                            as range_high,
        null::integer                                            as provider_id,
        null::integer                                            as visit_occurrence_id,
        null::integer                                            as visit_detail_id,
        measurement_source_value                                 as measurement_source_value,
        null::integer                                            as measurement_source_concept_id,
        null::text                                                as unit_source_value,
        null::integer                                            as unit_source_concept_id,
        value_as_number::text                                    as value_source_value

    from unioned

)

select * from mapped