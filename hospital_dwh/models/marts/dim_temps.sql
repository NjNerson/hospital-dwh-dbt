{{ config(materialized='table') }}

select distinct
    format('%02d%02d', Heure, Minute) as TempsID,
    Heure,
    Minute,

    case
        when Heure between 0 and 5 then '00h-05h'
        when Heure between 6 and 11 then '06h-11h'
        when Heure between 12 and 17 then '12h-17h'
        when Heure between 18 and 23 then '18h-23h'
        else 'Inconnu'
    end as TrancheHoraire,

    case
        when Heure between 6 and 13 then 'Matin'
        when Heure between 14 and 21 then 'Après-midi'
        else 'Nuit'
    end as Shift

from {{ ref('stg_visits') }}