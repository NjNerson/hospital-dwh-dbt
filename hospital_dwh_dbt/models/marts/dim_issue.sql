{{ config(materialized='table') }}

select distinct
    to_hex(md5(IssueSortie)) as IssueID,
    IssueSortie as LabelIssue,
    HospitalisationFlag

from {{ ref('stg_visits') }}