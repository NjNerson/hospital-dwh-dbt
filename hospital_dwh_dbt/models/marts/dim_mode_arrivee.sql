{{ config(materialized='table') }}

select distinct
    to_hex(md5(ModeArrivee)) as ModeArriveeID,
    ModeArrivee as LabelModeArrivee

from {{ ref('stg_visits') }}