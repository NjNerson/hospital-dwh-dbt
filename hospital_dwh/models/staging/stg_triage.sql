{{ config(materialized='view') }}

with

source as (
    select *
    from {{ source('raw_hospital','triage') }}
),

renamed_cleaned as (

    select
        cast(triage_id as string) as TriageID,
        cast(visit_id as string) as VisitID,

        initcap(trim(niveau_gravite)) as NiveauGravite,

        cast(priorite as int64) as Priorite,
        cast(score_triage as int64) as ScoreTriage,

        cast(oxygene_flag as int64) as OxygeneFlag,
        cast(constantes_relevees_flag as int64) as ConstantesReleveesFlag

    from source

)


select *
from renamed_cleaned