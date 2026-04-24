{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('raw_hospital', 'actes_medicaux') }}

),

renamed_cleaned as (

    select
        cast(acte_id as string) as ActeID,
        cast(visit_id as string) as VisitID,

        -- standardisation texte
        initcap(trim(type_acte)) as TypeActe,
        initcap(trim(libelle_acte)) as LibelleActe,

        -- types numériques
        cast(cout_acte as float64) as CoutActe,
        cast(duree_estimee_min as int64) as DureeEstimeeMin

    from source

)

select *
from renamed_cleaned