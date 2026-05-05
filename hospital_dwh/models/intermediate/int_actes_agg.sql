{{ config(materialized='view') }}

with actes as (

    select *
    from {{ ref('stg_actes_medicaux') }}

),

aggregated as (

    select
        VisitID,

        count(ActeID) as NbActes,
        sum(CoutActe) as CoutTotalActes,
        sum(DureeEstimeeMin) as DureeTotaleActesMin

    from actes
    group by VisitID

)

select *
from aggregated