{{ config(materialized='table') }}

select distinct
    to_hex(md5(NiveauGravite)) as GraviteID,
    NiveauGravite,
    Priorite,
    ScoreTriage

from {{ ref('stg_triage') }}