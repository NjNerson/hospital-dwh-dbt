{{ config(materialized='view') }}

with

source as (

    select *
    from {{ source('raw_hospital', 'patients') }}

),

renamed_cleaned as (

    select
        cast(patient_id as string) as PatientID,

        case
            when lower(trim(sexe)) in ('m', 'male', 'masculin', 'homme') then 'Male'
            when lower(trim(sexe)) in ('f', 'female', 'féminin', 'feminin', 'femme') then 'Female'
            else 'Unknown'
        end as Sexe,

        cast(date_naissance as date) as DateNaissance,

        case
            when zone_residence is null or trim(zone_residence) = '' then 'Inconnue'
            else initcap(trim(zone_residence))
        end as ZoneResidence

    from source

),

with_age as (

    select
        PatientID,
        Sexe,
        DateNaissance,
        date_diff(current_date(), DateNaissance, year) as Age,
        ZoneResidence

    from renamed_cleaned

),

final as (

    select
        PatientID,
        Sexe,
        DateNaissance,
        Age,

        case
            when Age between 0 and 5 then '0-5 ans'
            when Age between 6 and 17 then '6-17 ans'
            when Age between 18 and 35 then '18-35 ans'
            when Age between 36 and 59 then '36-59 ans'
            when Age >= 60 then '60+ ans'
            else 'Inconnu'
        end as TrancheAge,

        -- tranche simple
        case
            when Age < 18 then 'Enfant'
            when Age < 60 then 'Adulte'
            else 'Senior'
        end as GroupeAge,

        ZoneResidence

    from renamed_cleaned

)

select *
from final