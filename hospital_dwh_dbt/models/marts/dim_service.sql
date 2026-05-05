{{ config(materialized='table') }}

select distinct
    ServiceID,
    NomService,
    TypeService,
    NiveauCriticite,
    CapaciteTheorique

from {{ ref('stg_services') }}