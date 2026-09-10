-- Ruta sugerida: models/staging/stg_observation.sql
-- Union de stg_observation_binary (4 variables Si/No) y
-- stg_observation_health_status (HUQ010, escala ordinal).
-- cdm/observation.sql es un simple passthrough de este modelo.

select * from {{ ref('stg_observation_binary') }}

union all

select * from {{ ref('stg_observation_health_status') }}
