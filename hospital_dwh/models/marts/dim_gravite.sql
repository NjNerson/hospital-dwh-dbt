{{ config(materialized='table') }}

select distinct
    NiveauGravite as GraviteID,
    NiveauGravite,
    Priorite,
    ScoreTriage

from {{ ref('stg_triage') }}