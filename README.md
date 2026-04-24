# Hospital Data Warehouse (dbt)
## hospital-dwh-dbt

Ce projet utilise **dbt (Data Build Tool)** pour transformer et modéliser les données de santé brutes en un entrepôt de données (DWH) analytique et structuré.

## 🚀 Objectif
L'objectif de ce dépôt est de fournir une solution ELT (Extract, Load, Transform) pour centraliser les données hospitalières (patients, admissions, soins, facturation) afin de faciliter le reporting et l'analyse clinique.

## 🏗️ Architecture des modèles (dbt)
Le projet suit l'architecture recommandée par dbt :
- **Staging (`models/staging`)** : Nettoyage et normalisation des sources brutes (ex: renommage de colonnes, typage des données).
- **Intermediate (`models/intermediate`)** : Application de la logique métier complexe et jointures entre les entités (ex: calcul de la durée de séjour).
- **Marts (`models/marts`)** : Tables finales prêtes pour la BI (ex: dashboarding sur l'occupation des lits, analyses de réadmission).

## 🛠️ Installation et Configuration
1. Clonez le dépôt :
   ```bash
   git clone https://github.com
   cd hospital-dwh-dbt
   ```
2. Installez dbt (si nécessaire) et configurez votre fichier `profiles.yml`.
3. Installez les dépendances :
   ```bash
   dbt deps
   ```

## 📈 Utilisation
- Pour exécuter tous les modèles : `dbt run`
- Pour lancer les tests de qualité de données : `dbt test`
- Pour générer la documentation : `dbt docs generate && dbt docs serve`

## ✅ Qualité des données
Des tests automatiques sont implémentés pour garantir :
- L'unicité des IDs patients.
- La validité des dates d'admission/sortie.
- La non-nullité des champs critiques.

