{{ config(materialized='table') }}

select distinct
    PatientID,
    Sexe,
    DateNaissance,

    case
        when Age between 0 and 5 then '0-5 ans'
        when Age between 6 and 17 then '6-17 ans'
        when Age between 18 and 35 then '18-35 ans'
        when Age between 36 and 59 then '36-59 ans'
        when Age >= 60 then '60+ ans'
        else 'Inconnu'
    end as TrancheAge,

    case
        when Age < 18 then 'Enfant'
        when Age < 60 then 'Adulte'
        when Age >= 60 then 'Senior'
        else 'Inconnu'
    end as GroupeAge

from {{ ref('stg_patients') }}