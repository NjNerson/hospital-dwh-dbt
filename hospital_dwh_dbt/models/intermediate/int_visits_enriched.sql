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

        coalesce(t.TriageID, 'T_UNKNOWN') as TriageID,
        coalesce(t.NiveauGravite, 'Inconnue') as NiveauGravite,
        coalesce(t.Priorite, 0) as Priorite,
        coalesce(t.ScoreTriage, 0) as ScoreTriage,
        coalesce(t.OxygeneFlag, 0) as OxygeneFlag,
        coalesce(t.ConstantesReleveesFlag, 0) as ConstantesReleveesFlag,

        coalesce(s.ServiceID, 'S_UNKNOWN') as ServiceID,
        coalesce(s.NomService, 'Service inconnu') as NomService,
        coalesce(s.TypeService, 'Inconnu') as TypeService,
        coalesce(s.NiveauCriticite, 'Inconnue') as NiveauCriticite,
        coalesce(s.CapaciteTheorique, 0) as CapaciteTheorique,

        coalesce(c.NbActes, 0) as NbActesDeclare,
        coalesce(c.CoutConsultation, 0) as CoutConsultation,
        coalesce(c.CoutActes, 0) as CoutActes,
        coalesce(c.CoutMedicaments, 0) as CoutMedicaments,
        coalesce(c.CoutTotal, 0) as CoutTotal,

        coalesce(a.NbActes, 0) as NbActesCalcule,
        coalesce(a.CoutTotalActes, 0) as CoutTotalActes,
        coalesce(a.DureeTotaleActesMin, 0) as DureeTotaleActesMin,

        case when p.PatientID is null then 1 else 0 end as PatientMissingFlag,
        case when t.VisitID is null then 1 else 0 end as TriageMissingFlag,
        case when s.ServiceID is null then 1 else 0 end as ServiceMissingFlag,
        case when c.VisitID is null then 1 else 0 end as CoutMissingFlag,
        case when a.VisitID is null then 1 else 0 end as ActesMissingFlag

    from visits v

    left join patients p
        on v.PatientID = p.PatientID

    left join triage t
        on v.VisitID = t.VisitID

    left join services s
        on lower(trim(v.ServiceOrientationInitiale)) = lower(trim(s.NomService))

    left join couts c
        on v.VisitID = c.VisitID

    left join actes a
        on v.VisitID = a.VisitID

)

select *
from final