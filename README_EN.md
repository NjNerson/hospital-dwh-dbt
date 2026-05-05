# 🏥 Hospital Emergency Data Warehouse

## 📌 Overview

This project implements a complete **ELT pipeline** to analyze hospital emergency department data.

It transforms raw operational data into reliable, structured and analytics-ready datasets that can be used in BI dashboards.  
The goal is to build an analytical **Data Warehouse** that helps understand emergency activity, waiting times, service workload and costs.

---

## 🎯 Project Objective

The project aims to answer business questions such as:

- When are emergency department peak hours?
- Which services are the most overloaded?
- What is the average patient waiting time?
- Are severe cases handled faster?
- What is the hospitalization rate after emergency visits?
- What is the average cost of an emergency visit?

---

## 🧩 Business Problem

Emergency departments receive patients continuously, but activity varies significantly depending on time, day, patient profile, service and severity level.

Without a Data Warehouse, hospital data remains scattered and difficult to analyze.  
Decision-makers may lack visibility to:

- anticipate workload peaks;
- organize medical teams;
- identify overloaded services;
- monitor waiting times;
- analyze costs;
- improve patient care quality.

---

## 💼 Business Value

This project provides business value through:

- **Operational visibility**: monitoring visits, waiting times and service workload.
- **Resource optimization**: helping allocate teams and capacity based on real demand.
- **Care quality improvement**: monitoring waiting times, severity and patient outcomes.
- **Financial analysis**: tracking costs by visit, service and severity level.
- **Decision support**: providing BI dashboards for hospital managers.

---

## 🧱 Global Architecture

```text
CSV Sources
   ↓
Google Cloud Storage
   ↓
Airbyte Cloud
   ↓
BigQuery - Raw Layer
   ↓
dbt
   ↓
Staging → Intermediate → Mart / Gold
   ↓
Metabase
   ↓
BI Dashboards
```

---

## 🏗️ Project Structure

```text
HOSPITAL-DWH-DBT/
│
├── .venv/
│
├── hospital_dwh/
│   ├── analyses/
│   ├── logs/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── seeds/
│   ├── snapshots/
│   ├── target/
│   ├── tests/
│   ├── dbt_project.yml
│   └── README.md
│
├── logs/
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt
```

---

## 🔄 dbt Architecture

The project follows a **Medallion-style architecture**:

```text
Bronze → Silver → Gold
```

In this project:

```text
raw_hospital          = Bronze
staging_hospital      = Silver - cleaning
intermediate_hospital = Silver - enrichment
mart_hospital         = Gold / BI
```

---

## 🔹 Staging

Staging models clean each raw source independently.

Goals:

- remove Airbyte technical columns;
- cast data types;
- rename columns clearly;
- standardize values;
- handle null or empty values.

Examples:

- `stg_patients`
- `stg_visits`
- `stg_triage`
- `stg_services`
- `stg_actes_medicaux`
- `stg_couts_visite`

---

## 🔹 Intermediate

Intermediate models prepare business logic before the final analytical model.

Goals:

- aggregate medical acts by visit;
- join visits with patients, triage, services, costs and acts;
- create a central enriched model with a clear grain.

Models:

- `int_actes_agg`
- `int_visits_enriched`

---

## 🔹 Mart / Gold

The mart contains final BI-ready tables.

It is organized as a **star schema**.

### Fact Table

- `fact_urgences`  
  One row represents one emergency visit.

### Dimensions

- `dim_patient`
- `dim_date`
- `dim_temps`
- `dim_service`
- `dim_gravite`
- `dim_mode_arrivee`
- `dim_issue`

---

## ⭐ Star Schema

> Add the star schema diagram here.

```text
                 dim_patient
                      |
dim_date ---- fact_urgences ---- dim_service
                      |
                 dim_temps
                      |
                dim_gravite
                      |
             dim_mode_arrivee
                      |
                  dim_issue
```

### Recommended image location

Place the image in:

```text
images/star_schema.png
```

Then display it here:

```md
![Star Schema](images/star_schema.png)
```

---

## 📊 Main KPIs

| KPI | Calculation | Business Use |
|---|---|---|
| Total visits | `SUM(PassageCount)` | Measure overall workload |
| Average waiting time | `AVG(TempsAttenteMin)` | Monitor delays |
| Average treatment duration | `AVG(DureePriseEnChargeMin)` | Measure operational efficiency |
| Hospitalization rate | `SUM(IsHospitalised) / SUM(PassageCount)` | Monitor bed pressure |
| Average cost per visit | `SUM(CoutTotal) / SUM(PassageCount)` | Analyze financial impact |
| Average number of acts | `AVG(NbActes)` | Evaluate medical complexity |

---

## 📸 Metabase Dashboards

> Add dashboard screenshots here.

```text
images/dashboard_overview.png
images/service_analysis.png
images/time_analysis.png
images/cost_analysis.png
```

Example:

```md
![Dashboard Overview](images/dashboard_overview.png)
```

---

## ⚙️ Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/<your-repo>
cd hospital-dwh-dbt
```

### 2. Create a virtual environment

```bash
python -m venv .venv
.venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Go to the dbt project

```bash
cd hospital_dwh
```

### 5. Configure `profiles.yml`

The `profiles.yml` file must contain the BigQuery connection.

Never commit:

- GCP JSON key;
- `.env` file;
- credentials.

### 6. Run the dbt pipeline

```bash
dbt build
```

### 7. Generate dbt documentation

```bash
dbt docs generate
dbt docs serve
```

---

## 📦 Metabase with Docker

### First run

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

Access:

```text
http://localhost:3000
```

### Start / stop

```bash
docker start metabase
docker stop metabase
```

### Auto-start

```bash
docker update --restart unless-stopped metabase
```

---

## 🔐 Connecting Metabase to BigQuery

Create a dedicated GCP service account for Metabase.

Required roles:

- BigQuery Data Viewer;
- BigQuery Job User.

Exposed dataset:

```text
mart_hospital
```

In Metabase:

```text
Admin → Databases → Add Database → BigQuery
```

---

## ⚙️ Automation

Current state:

- Airbyte ingestion is triggered manually;
- dbt transformations are triggered manually;
- Metabase runs locally with Docker.

Possible improvements:

- schedule `dbt build`;
- use Windows Task Scheduler or cron;
- integrate an orchestrator such as Kestra, Airflow or Prefect;
- automate the sequence Airbyte → dbt → BI.

---

## ✅ Data Quality

The project uses dbt tests:

- `not_null`
- `unique`
- `accepted_values`
- `relationships`

These tests ensure:

- unique identifiers;
- valid categorical values;
- consistency between fact and dimensions;
- reliability of BI-exposed data.

---

## 🧠 Skills Demonstrated

- Data Engineering
- ELT Pipeline
- Google BigQuery
- Airbyte
- dbt
- Medallion Architecture
- Star Schema Modeling
- Data Quality Testing
- BI with Metabase
- Business Analysis and KPIs

---

## 🚧 Future Improvements

- full orchestration;
- automated Airbyte syncs and dbt runs;
- addition of HR/medical staff data;
- pipeline monitoring;
- cloud deployment for Metabase;
- predictive analysis of emergency workload peaks.

---

## 👤 Author

**Nerson**  
Data Engineering & Analytics
