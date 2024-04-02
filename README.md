Le but de cet exercice est de tester vos capacités techniques et de réfléxion pour répondre à un problème donné.

# Contexte

Vous développez une plateforme de mesure d'impact dans la restauration. 
Vos clients vous fournissent des factures au format PDF, qui sont envoyées à un outil externe pour être analysées par OCR.

Cet outil vous répond par webhook avec le contenu JSON de la facture.

En base de données, vous avez une liste de fournisseurs connus, repérés par leur nom mais aussi d'autres attributs qui peuvent apparaître dans les factures tels que leur RIB ou numéro de TVA.
Pour certains de ces fournisseurs, vous savez qu'ils ne fournissent que certaines catégories de produit, ou que l'ensemble de leurs produits répond à un ou plusieur labels.

Vous disposez de [la base Ademe Agribalyse, la base de données environnementale de référence sur des produits agricoles et alimentaires, au format xlsx.](https://data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/metadata-attachments/AGRIBALYSE3.1.1_produits%20alimentaires.xlsx)
Elle comprend notamment l'impact carbone ainsi que la catégortie de chaque produit.

# Exercice

À l'aide des informations forunies dans les fichiers annexes, ainsi que [la base agribalyse](https://data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/metadata-attachments/AGRIBALYSE3.1.1_produits%20alimentaires.xlsx), nous souhaitons obtenir les éléments suivants :

- Un listing de chaque élément de facture détecté, avec les informations suivantes :
  - Lien (ou non) avec la base agribalyse 
  - Catégorie de produit (cf base agribalyse)
  - Provenance (cf règles métier)
  - BIO ? (cf règles métier)
- Répartition globale des poids commandés par **catégorie de produits**, **provenance**, **présence du label BIO**
- Estimation de l'impact carbone de la commande

# Règles métier

## Label BIO
Nous cherchons à détecter les produits durables, par souci de simplification de l'exercice, on ne cherchera qu'à identifier les produits ayant le label BIO, contenant souvent les mentions "bio" ou "AB" dans leur nomenclature.

## Provenance
La provenance des produits est parfois présente dans la description. Il peut s'agir du nom complet du pays, ou du code ISO3166 Alpha2 ou Alpha3.

Voici l'impact carbone à appliquer pour chaque provenance, exprimé en KG de Co2 équivalent par KG de produit.

**Même pays** : 0.05kgc02e/kg

**Même continent** : 0.15 kgco2e/kg

**Autre continent**: 0.3 kgc02e/kg

**Provenance inconnue** : 0.2 kgc02e/kg

## Poids
Par soucis de simplification, vous pouvez considérer que la quantité renvoyée dans le payload de l'outil d'OCR est toujours en KG.

# Contraintes & précisions
- Un résultat approximatif est acceptable, le but étant de préparer le travail avant une revue manuelle.
- Vous devez générer une application Rails afin de créer des modèles et de stocker les données en base sous un format facilement exploitable.
- Vous devez utiliser PostgreSQL
- Vous êtes libres concernant la structure des tables, que vous devez inférer selon les données à votre disposition
- En sortie, nous attendons un / plusieurs CSV / XLSX (aucune route n'est à prévoir dans l'application Rails) 
- En bonus, des graphiques permettant de visualiser la donnée sont les bienvenus
- L'utilisation de `thor` afin de faciliter l'ingestion des données et la génération des résultats via la CLI est recommandée 
