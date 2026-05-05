# 🏥 Hospital Emergency Data Warehouse

## 📌 Présentation

Ce projet implémente un pipeline **ELT complet** pour analyser les passages aux urgences hospitalières.

Il transforme des données brutes issues d’un contexte hospitalier en données fiables, structurées et exploitables dans un outil BI.  
L’objectif est de construire un **Data Warehouse analytique** capable d’aider à mieux comprendre l’activité des urgences, les délais de prise en charge, la charge des services et les coûts associés.

---

## 🎯 Objectif du projet

Le projet vise à répondre à des questions métier comme :

- Quels sont les moments de forte affluence aux urgences ?
- Quels services sont les plus sollicités ?
- Quel est le temps d’attente moyen des patients ?
- Les cas graves sont-ils pris en charge plus rapidement ?
- Quel est le taux d’hospitalisation après passage aux urgences ?
- Quel est le coût moyen d’un passage aux urgences ?

---

## 🧩 Problème métier

Un service d’urgences reçoit des patients en continu, mais l’activité varie fortement selon l’heure, le jour, le type de patient, le service concerné ou le niveau de gravité.

Sans Data Warehouse, les données restent dispersées et difficiles à exploiter.  
Les responsables hospitaliers peuvent manquer de visibilité pour :

- anticiper les pics d’activité ;
- organiser les équipes ;
- identifier les services sous tension ;
- suivre les délais de prise en charge ;
- analyser les coûts ;
- améliorer la qualité de service.

---

## 💼 Valeur business

Ce projet apporte une valeur métier sur plusieurs axes :

- **Meilleure visibilité opérationnelle** : suivi des passages, délais et services sollicités.
- **Optimisation des ressources** : aide à mieux répartir les équipes et capacités selon les périodes de forte charge.
- **Amélioration de la qualité de prise en charge** : suivi des temps d’attente, de la gravité et de l’issue des patients.
- **Analyse financière** : suivi des coûts par visite, service et niveau de gravité.
- **Aide à la décision** : dashboards BI exploitables par les responsables hospitaliers.

---

## 🧱 Architecture globale

```text
Sources CSV
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
Dashboards BI
```

---

## 🏗️ Architecture du projet

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

## 🔄 Architecture dbt

Le projet suit une logique proche de l’architecture **Medallion** :

```text
Bronze → Silver → Gold
```

Dans ce projet :

```text
raw_hospital          = Bronze
staging_hospital      = Silver - nettoyage
intermediate_hospital = Silver - enrichissement
mart_hospital         = Gold / BI
```

---

## 🔹 Staging

Les modèles staging nettoient les sources brutes une par une.

Objectifs :

- supprimer les colonnes techniques Airbyte ;
- typer correctement les données ;
- renommer les colonnes ;
- standardiser les valeurs ;
- gérer les valeurs nulles ou vides.

Exemples :

- `stg_patients`
- `stg_visits`
- `stg_triage`
- `stg_services`
- `stg_actes_medicaux`
- `stg_couts_visite`

---

## 🔹 Intermediate

Les modèles intermediate préparent la logique métier avant le modèle final.

Objectifs :

- agréger les actes médicaux par visite ;
- joindre les visites avec les patients, le triage, les services, les coûts et les actes ;
- obtenir une table centrale enrichie avec une granularité claire.

Modèles :

- `int_actes_agg`
- `int_visits_enriched`

---

## 🔹 Mart / Gold

Le mart contient les tables finales prêtes pour l’analyse BI.

Il est organisé en **schéma étoile** :

### Table de faits

- `fact_urgences`  
  Une ligne représente un passage aux urgences.

### Dimensions

- `dim_patient`
- `dim_date`
- `dim_temps`
- `dim_service`
- `dim_gravite`
- `dim_mode_arrivee`
- `dim_issue`

---

## ⭐ Schéma en étoile

> Ajouter ici le diagramme du schéma en étoile.

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

### Emplacement recommandé pour l’image

Place l’image dans :

```text
images/star_schema.png
```

Puis affiche-la ici :

```md
![Schéma en étoile](images/star_schema.png)
```

---

## 📊 KPI principaux

| KPI | Calcul | Utilité métier |
|---|---|---|
| Nombre de passages | `SUM(PassageCount)` | Mesurer la charge globale |
| Temps d’attente moyen | `AVG(TempsAttenteMin)` | Suivre les délais |
| Durée moyenne de prise en charge | `AVG(DureePriseEnChargeMin)` | Mesurer l’efficacité opérationnelle |
| Taux d’hospitalisation | `SUM(IsHospitalised) / SUM(PassageCount)` | Suivre la pression sur les lits |
| Coût moyen par passage | `SUM(CoutTotal) / SUM(PassageCount)` | Analyser l’impact financier |
| Nombre moyen d’actes | `AVG(NbActes)` | Évaluer la complexité médicale |

---

## 📸 Dashboards Metabase

> Ajouter ici les captures des dashboards.

```text
images/dashboard_overview.png
images/service_analysis.png
images/time_analysis.png
images/cost_analysis.png
```

Exemple :

```md
![Dashboard Overview](images/dashboard_overview.png)
```

---

## ⚙️ Installation et configuration

### 1. Cloner le projet

```bash
git clone https://github.com/<your-repo>
cd hospital-dwh-dbt
```

### 2. Créer un environnement virtuel

```bash
python -m venv .venv
.venv\Scripts\activate
```

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Aller dans le projet dbt

```bash
cd hospital_dwh
```

### 5. Configurer `profiles.yml`

Le fichier `profiles.yml` doit contenir la connexion BigQuery.

Ne jamais commiter :

- clé JSON GCP ;
- fichier `.env` ;
- credentials.

### 6. Exécuter le pipeline dbt

```bash
dbt build
```

### 7. Générer la documentation dbt

```bash
dbt docs generate
dbt docs serve
```

---

## 📦 Metabase avec Docker

### Premier lancement

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

Accès :

```text
http://localhost:3000
```

### Démarrer / arrêter

```bash
docker start metabase
docker stop metabase
```

### Démarrage automatique

```bash
docker update --restart unless-stopped metabase
```

---

## 🔐 Connexion Metabase à BigQuery

Créer un service account GCP dédié à Metabase.

Rôles nécessaires :

- BigQuery Data Viewer ;
- BigQuery Job User.

Dataset exposé :

```text
mart_hospital
```

Dans Metabase :

```text
Admin → Databases → Add Database → BigQuery
```

---

## ⚙️ Automatisation

État actuel :

- ingestion Airbyte lancée manuellement ;
- transformation dbt lancée manuellement ;
- Metabase lancé localement avec Docker.

Améliorations possibles :

- planifier `dbt build` ;
- utiliser Windows Task Scheduler ou cron ;
- intégrer un orchestrateur comme Kestra, Airflow ou Prefect ;
- automatiser la séquence Airbyte → dbt → BI.

---

## ✅ Qualité des données

Le projet utilise les tests dbt :

- `not_null`
- `unique`
- `accepted_values`
- `relationships`

Ces tests garantissent :

- l’unicité des identifiants ;
- la validité des valeurs catégorielles ;
- la cohérence entre la table de faits et les dimensions ;
- la fiabilité des données exposées au BI.

---

## 🧠 Compétences démontrées

- Data Engineering
- Pipeline ELT
- Google BigQuery
- Airbyte
- dbt
- Architecture Medallion
- Modélisation en étoile
- Tests qualité
- BI avec Metabase
- Analyse métier et KPI

---

## 🚧 Améliorations futures

- orchestration complète ;
- automatisation des syncs Airbyte et runs dbt ;
- ajout de données RH/personnel médical ;
- monitoring du pipeline ;
- déploiement Metabase cloud ;
- analyse prédictive des pics d’affluence.

---

## 👤 Auteur

**Nerson**  
Data Engineering & Analytics
