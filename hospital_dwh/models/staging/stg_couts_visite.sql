{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('raw_hospital', 'couts_visite') }}

),

renamed_cleaned as (

    select
        cast(visit_id as string) as VisitID,

        cast(nb_actes as int64) as NbActes,
        cast(cout_consultation as float64) as CoutConsultation,
        cast(cout_actes as float64) as CoutActes,
        cast(cout_medicaments as float64) as CoutMedicaments,
        cast(cout_total as float64) as CoutTotal

    from source

)

select *
from renamed_cleaned