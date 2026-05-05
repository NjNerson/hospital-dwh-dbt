# 🏥 Hospital Emergency Data Warehouse

## hospital-dwh

Ce projet implémente un pipeline **ELT complet** pour analyser les passages aux urgences hospitalières, depuis les données brutes jusqu’à des dashboards BI exploitables.

L’objectif n’est pas seulement technique : le projet vise à transformer des données opérationnelles hospitalières en **indicateurs décisionnels** capables d’aider un hôpital à mieux comprendre son activité, anticiper les périodes de surcharge et améliorer la gestion de ses ressources.

---

## 🚀 Objectif du projet

Construire un **Data Warehouse analytique** permettant d’analyser les passages aux urgences d’un hôpital selon plusieurs axes :

- temps d’attente ;
- durée de prise en charge ;
- charge par service ;
- niveau de gravité ;
- mode d’arrivée ;
- issue de sortie ;
- coût de prise en charge.

Le but final est de fournir une base fiable pour des dashboards BI permettant de soutenir la prise de décision.

---

## 🧩 Problème métier à résoudre

Un service d’urgences fait face à plusieurs difficultés :

- la fréquentation varie fortement selon l’heure, le jour ou la période ;
- certains services peuvent être beaucoup plus sollicités que d’autres ;
- les temps d’attente peuvent augmenter en cas de surcharge ;
- les cas graves doivent être identifiés et suivis rapidement ;
- les coûts de prise en charge peuvent varier selon les actes, la gravité et le service ;
- les données brutes existent, mais elles sont souvent dispersées, peu nettoyées et difficiles à exploiter directement.

Sans Data Warehouse, il est difficile pour les décideurs hospitaliers de répondre clairement à des questions comme :

- Quand les urgences sont-elles le plus saturées ?
- Quels services supportent la plus forte charge ?
- Les patients graves sont-ils pris en charge suffisamment rapidement ?
- Quels types de cas génèrent le plus de coûts ?
- Quelle part des patients est hospitalisée après passage aux urgences ?
- Comment mieux répartir les ressources médicales selon la charge réelle ?

---

## 💼 Valeur business

Ce projet apporte plusieurs bénéfices côté métier :

### 1. Meilleure visibilité sur l’activité des urgences

Les responsables peuvent suivre le volume de passages, les pics d’affluence et la répartition des patients selon les services.

### 2. Aide à l’optimisation des ressources

L’analyse par heure, jour, service et gravité peut aider à mieux planifier les équipes, les salles, les équipements et les capacités de prise en charge.

### 3. Réduction potentielle des délais d’attente

En identifiant les périodes et services où les temps d’attente sont élevés, l’hôpital peut cibler les points de blocage.

### 4. Suivi de la qualité de prise en charge

Les indicateurs comme le temps d’attente, l’hospitalisation, l’usage d’oxygène ou la gravité permettent de mieux suivre le parcours patient.

### 5. Analyse financière

Les coûts de consultation, actes, médicaments et coûts totaux permettent d’évaluer l’impact financier des urgences selon les services et les profils de cas.

### 6. Base solide pour la décision

Le modèle final permet de construire des dashboards clairs pour les responsables hospitaliers, les analystes et les équipes de pilotage.

---

## ❓ Questions métier couvertes

Le Data Warehouse permet de répondre à des questions comme :

### Activité & affluence

- Combien de passages aux urgences sont enregistrés sur une période ?
- Quels jours ou quelles heures concentrent le plus de passages ?
- Les week-ends sont-ils plus chargés que les jours ouvrés ?

### Délais & performance opérationnelle

- Quel est le temps d’attente moyen ?
- Quels services ont les délais les plus élevés ?
- La durée de prise en charge varie-t-elle selon la gravité ?

### Services hospitaliers

- Quels services sont les plus sollicités ?
- Quels services traitent les cas les plus graves ?
- Quels services génèrent les coûts les plus importants ?

### Gravité & triage

- Quelle est la répartition des passages par niveau de gravité ?
- Les cas critiques sont-ils associés à des durées ou coûts plus élevés ?
- Quel est le lien entre gravité et hospitalisation ?

### Coûts

- Quel est le coût moyen par passage ?
- Quelle part du coût vient des actes, médicaments ou consultations ?
- Quels types de passages coûtent le plus ?

### Issue de sortie

- Quel est le taux d’hospitalisation ?
- Quelle proportion de patients retourne à domicile ?
- Les patients référés ou arrivés en ambulance sont-ils plus souvent hospitalisés ?

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

## 🏗️ Architecture des modèles dbt

Le projet suit une logique proche de l’architecture **Medallion** :

```text
Bronze → Silver → Gold
```

Dans ce projet :

```text
raw_hospital          = Bronze
staging_hospital      = Silver - nettoyage
intermediate_hospital = Silver - enrichissement
mart_hospital         = Gold
```

---

### 🔹 Staging (`models/staging`)

Objectif : transformer les données brutes en tables propres et typées.

Actions réalisées :

- suppression des colonnes techniques Airbyte ;
- typage des colonnes ;
- renommage clair ;
- standardisation des valeurs ;
- nettoyage des valeurs nulles ou vides.

Exemples :

- `stg_patients`
- `stg_visits`
- `stg_triage`
- `stg_services`
- `stg_actes_medicaux`
- `stg_couts_visite`

---

### 🔹 Intermediate (`models/intermediate`)

Objectif : préparer la logique métier avant le modèle final.

Actions réalisées :

- agrégation des actes médicaux par visite ;
- jointure des visites avec patients, triage, services, coûts et actes ;
- création d’une table enrichie avec une granularité claire.

Modèles :

- `int_actes_agg`
- `int_visits_enriched`

La table `int_visits_enriched` sert de base centrale pour construire la table de faits.

---

### 🔹 Mart / Gold (`models/marts`)

Objectif : fournir un modèle final optimisé pour la BI.

Le mart est organisé en **schéma étoile**.

#### 📊 Table de faits

- `fact_urgences`
  - 1 ligne = 1 passage aux urgences

#### 📐 Dimensions

- `dim_patient`
- `dim_date`
- `dim_temps`
- `dim_service`
- `dim_gravite`
- `dim_mode_arrivee`
- `dim_issue`

---

## 📊 KPI principaux

Les KPI sont calculés à partir de la table `fact_urgences`.

| KPI                              | Calcul                                    | Utilité métier                                 |
| -------------------------------- | ----------------------------------------- | ---------------------------------------------- |
| Nombre de passages               | `SUM(PassageCount)`                       | Mesurer la charge globale                      |
| Temps d’attente moyen            | `AVG(TempsAttenteMin)`                    | Identifier les délais                          |
| Durée moyenne de prise en charge | `AVG(DureePriseEnChargeMin)`              | Suivre l’efficacité opérationnelle             |
| Taux d’hospitalisation           | `SUM(IsHospitalised) / SUM(PassageCount)` | Mesurer la gravité et la pression sur les lits |
| Coût moyen par passage           | `SUM(CoutTotal) / SUM(PassageCount)`      | Suivre l’impact financier                      |
| Nombre moyen d’actes             | `AVG(NbActes)`                            | Évaluer la complexité médicale                 |
| Usage d’oxygène                  | `SUM(UsedOxygen) / SUM(PassageCount)`     | Suivre certains besoins critiques              |

---

## 📸 Dashboards Metabase

Ajouter les captures dans le dossier `images/`.

### Vue globale

![Dashboard Overview](images/dashboard_overview.png)

### Analyse par service

![Service Analysis](images/service_analysis.png)

### Analyse temporelle

![Time Analysis](images/time_analysis.png)

### Analyse des coûts

![Cost Analysis](images/cost_analysis.png)

---

## 🛠️ Setup dbt

### 1. Cloner le projet

```bash
git clone https://github.com/<your-repo>
cd hospital-dwh
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

### 4. Configurer `profiles.yml`

Le fichier `profiles.yml` doit contenir la connexion BigQuery.

Ne jamais commiter :

- clé JSON GCP ;
- fichier `.env` ;
- credentials.

### 5. Exécuter le pipeline dbt

```bash
dbt build
```

### 6. Générer la documentation dbt

```bash
dbt docs generate
dbt docs serve
```

---

## 📦 Metabase – Mise en place locale avec Docker

### Lancer Metabase

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

Accès recommandé :

- uniquement au dataset `mart_hospital`.

Dans Metabase :

```text
Admin → Databases → Add Database → BigQuery
```

Dataset à exposer :

```text
mart_hospital
```

---

## ⚙️ Automatisation

État actuel :

- ingestion Airbyte lancée manuellement ;
- transformation dbt lancée manuellement ;
- dashboards Metabase consultables localement.

Améliorations possibles :

- planifier `dbt build` ;
- utiliser Windows Task Scheduler ou cron ;
- intégrer un orchestrateur comme Kestra, Airflow ou Prefect ;
- automatiser la séquence :
  - Airbyte sync ;
  - dbt build ;
  - validation des tests ;
  - mise à jour des dashboards.

---

## 📁 Structure du projet

```text
HOSPITAL-DWH/
│
├── hospital_dwh_dbt/
│ ├── models/
│ │ ├── staging/
│ │ ├── intermediate/
│ │ └── marts/
│ ├── macros/
│ ├── tests/
│ ├── seeds/
│ ├── snapshots/
│ └── dbt_project.yml
│
├── README.md
└── requirements.txt
```

---

## ✅ Qualité des données

Le projet utilise les tests dbt pour garantir :

- unicité des identifiants ;
- non-nullité des clés importantes ;
- validité des valeurs catégorielles ;
- relations entre table de faits et dimensions ;
- cohérence du modèle étoile.

Exemples :

- `not_null`
- `unique`
- `accepted_values`
- `relationships`

---

## 🧠 Compétences démontrées

Ce projet démontre :

- conception d’un pipeline ELT ;
- utilisation de GCP BigQuery ;
- ingestion avec Airbyte ;
- transformation avec dbt ;
- architecture Medallion ;
- modélisation en étoile ;
- tests qualité avec dbt ;
- exposition des données Gold à un outil BI ;
- création de KPI métier ;
- visualisation avec Metabase.

---

## 🚧 Limites et améliorations possibles

Limites actuelles :

- données synthétiques ;
- pas encore d’orchestration complète ;
- Metabase local ;
- pas de données détaillées sur le personnel médical.

Améliorations possibles :

- ajout d’un orchestrateur ;
- automatisation complète du pipeline ;
- ajout de données RH/personnel médical ;
- analyse prédictive des pics d’affluence ;
- dashboard public ou démo cloud ;
- monitoring du pipeline.

---

## 👤 Auteur

**Nerson**  
Data Engineering & Analytics
