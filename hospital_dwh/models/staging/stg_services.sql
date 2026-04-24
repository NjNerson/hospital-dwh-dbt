{{ config(materialized='view') }}

with

source as(
    select *
    from {{ source('raw_hospital', 'services') }}
),

renamed_cleaned as (
    select 
        cast(service_id as string) as ServiceID,
        
        initcap(trim(nom_service)) as NomService,
        initcap(trim(type_service)) as TypeService,
        initcap(trim(niveau_criticite)) as NiveauCriticite,

        cast(trim(capacite_theorique) as int) as CapaciteTheorique
    from source
)

select * 
from renamed_cleaned