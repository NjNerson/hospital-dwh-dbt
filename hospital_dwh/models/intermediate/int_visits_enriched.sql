{{ config(materialized='view') }}

with
visits as (

    select *
    from {{ ref('stg_visits') }}

),

patients as (

    select *
    from {{ ref('stg_patients') }}

),

triage as (

    select *
    from {{ ref('stg_triage') }}

),

services as (

    select *
    from {{ ref('stg_services') }}

),

couts as (

    select *
    from {{ ref('stg_couts_visite') }}

),

actes as (

    select *
    from {{ ref('int_actes_agg') }}

),

final as (

    select
        v.VisitID,
        v.PatientID,
        v.DateArrivee,
        v.DatetimeArrivee,
        v.HeureArrivee,
        v.Heure,
        v.Minute,

        v.ModeArrivee,
        v.MotifAdmission,
        v.ServiceOrientationInitiale,
        v.IssueSortie,
        v.HospitalisationFlag,
        v.TempsAttenteMin,
        v.DureePriseEnChargeMin,
        v.HospitalName,

        p.Sexe,
        p.DateNaissance,
        p.Age,
        p.ZoneResidence,

        t.TriageID,
        t.NiveauGravite,
        t.Priorite,
        t.ScoreTriage,
        t.OxygeneFlag,
        t.ConstantesReleveesFlag,

        s.ServiceID,
        s.NomService,
        s.TypeService,
        s.NiveauCriticite,
        s.CapaciteTheorique,

        c.NbActes as NbActesDeclare,
        c.CoutConsultation,
        c.CoutActes,
        c.CoutMedicaments,
        c.CoutTotal,

        a.NbActes as NbActesCalcule,
        a.CoutTotalActes,
        a.DureeTotaleActesMin

    from visits v

    left join patients p
        on v.PatientID = p.PatientID

    left join triage t
        on v.VisitID = t.VisitID

    left join services s
        on v.ServiceOrientationInitiale = s.NomService

    left join couts c
        on v.VisitID = c.VisitID

    left join actes a
        on v.VisitID = a.VisitID

)

select *
from final