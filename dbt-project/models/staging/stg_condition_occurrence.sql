
-- Ruta sugerida: models/cdm/condition_occurrence.sql
-- Union de stg_condition_occurrence_diabetes (DIQ010, con su logica
-- especial de 3 valores) y stg_condition_occurrence_mcq (las 12
-- condiciones autoinformadas de MCQ_L).
 
select * from {{ ref('stg_condition_occurrence_diabetes') }}
 
union all
 
select * from {{ ref('stg_condition_occurrence_mcq') }}
 