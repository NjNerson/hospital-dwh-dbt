{{ config(materialized='table') }}

select distinct
    to_hex(md5(format_date('%Y%m%d', DateArrivee))) as DateID,
    DateArrivee as DateComplete,

    extract(day from DateArrivee) as Jour,
    extract(month from DateArrivee) as Mois,
    format_date('%B', DateArrivee) as NomMois,
    extract(quarter from DateArrivee) as Trimestre,
    extract(year from DateArrivee) as Annee,
    format_date('%A', DateArrivee) as JourSemaine,

    case
        when extract(dayofweek from DateArrivee) in (1, 7) then true
        else false
    end as WeekendFlag

from {{ ref('stg_visits') }}