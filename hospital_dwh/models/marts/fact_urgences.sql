{{ config(materialized='table') }}

select
    VisitID,

    PatientID,

    to_hex(md5(format_date('%Y%m%d', DateArrivee))) as DateID,
    to_hex(md5(format('%02d%02d', Heure, Minute))) as TempsID,

    ServiceID,
    to_hex(md5(NiveauGravite)) as GraviteID,

    to_hex(md5(ModeArrivee)) as ModeArriveeID,
    to_hex(md5(IssueSortie)) as IssueID,

    TempsAttenteMin,
    DureePriseEnChargeMin,

    NbActesCalcule as NbActes,
    CoutConsultation,
    CoutActes,
    CoutMedicaments,
    CoutTotal,
    OxygeneFlag as UsedOxygen,
    HospitalisationFlag as IsHospitalised,

    1 as PassageCount

from {{ ref('int_visits_enriched') }}