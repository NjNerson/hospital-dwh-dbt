{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('raw_hospital', 'visites_urgences') }}

),

renamed_cleaned as (

    select
        cast(visit_id as string) as VisitID,
        cast(patient_id as string) as PatientID,

        cast(date_arrivee as date) as DateArrivee,
        cast(datetime_arrivee as datetime) as DatetimeArrivee,
        cast(heure_arrivee as time) as HeureArrivee,

        extract(hour from cast(heure_arrivee as time)) as Heure,
        extract(minute from cast(heure_arrivee as time)) as Minute,

        case
            when lower(trim(mode_arrivee)) = 'ambulance' then 'Ambulance'
            when lower(trim(mode_arrivee)) in ('walk-in', 'walk in', 'walkin') then 'Arrivée spontanée'
            when lower(trim(mode_arrivee)) in ('family transport', 'family_transport') then 'Transport familial'
            when lower(trim(mode_arrivee)) = 'referral' then 'Référé'
            when lower(trim(mode_arrivee)) = 'police/protection civile' then 'Police / Protection civile'
            else 'Autre'
        end as ModeArrivee,

        initcap(trim(motif_admission)) as MotifAdmission,
        initcap(trim(service_orientation_initiale)) as ServiceOrientationInitiale,
        initcap(trim(issue_sortie)) as IssueSortie,

        cast(hospitalisation_flag as int64) as HospitalisationFlag,
        cast(temps_attente_min as int64) as TempsAttenteMin,
        cast(duree_prise_en_charge_min as int64) as DureePriseEnChargeMin,

        initcap(trim(hospital_name)) as HospitalName

    from source

)

select *
from renamed_cleaned