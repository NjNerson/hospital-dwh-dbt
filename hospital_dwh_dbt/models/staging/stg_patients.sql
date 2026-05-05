{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('raw_hospital', 'patients') }}

),

renamed_cleaned as (

    select
        cast(patient_id as string) as PatientID,

        case
            when lower(trim(sexe)) in ('m', 'male', 'masculin', 'homme') then 'Homme'
            when lower(trim(sexe)) in ('f', 'female', 'féminin', 'feminin', 'femme') then 'Femme'
            else 'Inconnue'
        end as Sexe,

        cast(date_naissance as date) as DateNaissance,

        case
            when zone_residence is null or trim(zone_residence) = '' then 'Inconnue'
            else initcap(trim(zone_residence))
        end as ZoneResidence

    from source

),

final as (

    select
        PatientID,
        Sexe,
        DateNaissance,
        date_diff(current_date(), DateNaissance, year) as Age,
        ZoneResidence

    from renamed_cleaned

)

select *
from final