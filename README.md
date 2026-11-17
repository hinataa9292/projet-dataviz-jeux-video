# 🎮 Le marché mondial du jeu vidéo : ventes, studios et créateurs

Projet de data visualisation réalisé dans le cadre du TP **Data Visualisation – Open Data** (formation AJC).

La chaîne complète, de l'Open Data jusqu'à la présentation :

```
Open Data (CSV / Wikidata)  →  Import SQL (LOAD DATA INFILE)  →  MariaDB  →  ODBC 64 bits  →  Tableau Desktop  →  Story + PDF
```

---

## 📑 Sommaire
1. [Sources de données](#-sources-de-données)
2. [Outils utilisés](#-outils-utilisés)
3. [Structure du dépôt](#-structure-du-dépôt)
4. [Schéma de la base](#-schéma-de-la-base)
5. [Scripts SQL et ordre d'exécution](#-scripts-sql-et-ordre-dexécution)
6. [Qualité des données : contrôles et corrections](#-qualité-des-données--contrôles-et-corrections)
7. [Connexion ODBC](#-connexion-odbc)
8. [Tableaux de bord](#-tableaux-de-bord)
9. [Analyses statistiques](#-analyses-statistiques)
10. [Limites](#-limites)

---

## 📂 Sources de données

| Jeu de données | Source | Contenu | Lignes |
|---|---|---|---|
| `vgsales.csv` | [Kaggle – Video Game Sales](https://www.kaggle.com/datasets/gregorut/videogamesales) (données collectées sur VGChartz) | Ventes physiques de jeux (millions d'unités) par région : Amérique du Nord, Europe, Japon, Autres | 16 598 |
| `studios.csv` | [Wikidata](https://query.wikidata.org/) – requête SPARQL du 16/11/2026 | Studios et éditeurs de jeux vidéo, pays, ville du siège, année de création, coordonnées GPS | 4 439 |
| `createurs_de_jeux.csv` | [Wikidata](https://query.wikidata.org/) – requête SPARQL du 16/11/2026 | Personnes ayant conçu au moins un jeu vidéo (propriété *conçu par*, P287) : sexe, nationalité, année de naissance, nombre de jeux | 898 |

Les requêtes SPARQL utilisées sont fournies dans `sql/sparql_studios.rq` et `sql/sparql_createurs.rq`. Les données Wikidata sont publiées sous licence CC0.

---

## 🛠 Outils utilisés

| Étape | Outil |
|---|---|
| Base de données | MariaDB 10.6 (compatible MySQL), en local sur le port 3306 |
| Écriture et exécution SQL | VS Code + extension **SQLTools** (pilote MySQL/MariaDB) |
| Connecteur | Pilote **MySQL Connector/ODBC Unicode 64 bits** + DSN système |
| Visualisation | Tableau Desktop |
| Extraction Open Data | Wikidata Query Service (SPARQL) |

---

## 🗂 Structure du dépôt

```
projet_jv/
├── README.md
├── .gitignore
├── data/                         # Fichiers sources CSV
│   ├── vgsales.csv
│   ├── studios.csv
│   └── createurs_de_jeux.csv
├── sql/                          # Scripts SQL et SPARQL
│   ├── 01_creation_table.sql
│   ├── 02_import.sql
│   ├── 03_controle_qualite.sql
│   ├── 03b_corrections.sql
│   ├── 04_vue_tableau.sql
│   ├── 05_studios.sql
│   ├── 06_createurs_de_jeux.sql
│   ├── 07_bilan_avant_apres.sql
│   ├── sparql_studios.rq
│   └── sparql_createurs.rq
├── analyses/                     # Résultats des modèles statistiques (Tableau)
│   ├── regression.txt
│   └── clustering.txt
├── visualisation/
│   └── dashboard_jeux_video_monde.twbx   # Classeur packagé (extraits inclus)
├── captures/
│   ├── dashboard_1.png           # Ventes
│   ├── dashboard_2.png           # Studios
│   ├── dashboard_3.png           # Concepteurs
│   └── dashboard_4.png           # Analyses statistiques
└── presentation/
    ├── presentation_story.pdf    # Export de la Story Tableau
    └── presentation.pptx         # Support de l'oral
```

---

## 🧱 Schéma de la base

Base `jeux_video` (encodage `utf8mb4`) : 3 tables et 2 vues.

```mermaid
erDiagram
    ventes {
        INT id PK
        INT rang
        VARCHAR nom
        VARCHAR plateforme
        SMALLINT annee "NULL si inconnue"
        VARCHAR genre
        VARCHAR editeur
        DECIMAL ventes_na "millions d'unités"
        DECIMAL ventes_eu
        DECIMAL ventes_jp
        DECIMAL ventes_autres
        DECIMAL ventes_monde
    }
    v_ventes {
        "toutes les colonnes de ventes" _
        SMALLINT decennie "calculée"
    }
    studios {
        INT id PK
        VARCHAR wikidata_url
        VARCHAR nom
        VARCHAR pays
        VARCHAR ville
        SMALLINT annee_creation
        DECIMAL latitude
        DECIMAL longitude
        SMALLINT decennie_creation "colonne générée"
    }
    createurs_de_jeux {
        INT id PK
        VARCHAR wikidata_url
        VARCHAR nom
        VARCHAR sexe
        VARCHAR pays
        SMALLINT annee_naissance
        INT nb_jeux
        SMALLINT decennie_naissance "colonne générée"
    }
    v_createurs {
        "toutes les colonnes de createurs_de_jeux" _
        VARCHAR sexe_regroupe "Hommes / Femmes / Non-binaire / Non renseigné"
        TINYINT est_femme "0 ou 1"
        TINYINT sexe_connu "0 ou 1"
    }
    ventes ||--|| v_ventes : "vue : jeux sortis jusqu'en 2016"
    createurs_de_jeux ||--|| v_createurs : "vue : indicateurs calculés"
```

Les trois tables proviennent de sources indépendantes et n'ont **pas de clé commune** : elles sont analysées séparément, dans des dashboards distincts. Tableau utilise **3 sources de données** : `v_ventes`, `studios` et `v_createurs`.

**Pourquoi des colonnes calculées dans MariaDB ?** Le pilote ODBC générique de Tableau traduit mal certaines fonctions. Par exemple, `FLOOR()` devient `CAST(... AS BIGINT)`, ce que MariaDB refuse, et certaines comparaisons de texte provoquent une erreur de collation. Les décennies et les indicateurs 0/1 sont donc calculés côté base, dans des colonnes générées et des vues.

---

## 📜 Scripts SQL et ordre d'exécution

| Ordre | Script | Rôle |
|---|---|---|
| 1 | `01_creation_table.sql` | Crée la base `jeux_video` et la table `ventes` |
| 2 | `02_import.sql` | Importe `vgsales.csv` (`LOAD DATA INFILE`, `N/A` → `NULL`) |
| 3 | `05_studios.sql` | Crée et importe la table `studios` (années hors de 1850-2026 → `NULL`) |
| 4 | `06_createurs_de_jeux.sql` | Crée et importe `createurs_de_jeux`, puis crée la vue `v_createurs` |
| 5 | `03_controle_qualite.sql` | Contrôles : valeurs manquantes, doublons, cohérence des totaux, coordonnées, libellés |
| 6 | `03b_corrections.sql` | Corrige les anomalies détectées (script protégé, relançable sans risque) |
| 7 | `04_vue_tableau.sql` | Crée la vue `v_ventes` utilisée par Tableau |
| 8 | `07_bilan_avant_apres.sql` | Bilan chiffré avant / après corrections |

⚠️ Les chemins des fichiers CSV sont écrits en dur (`C:/projet_jv/data/...`). Adaptez-les si vous clonez le dépôt ailleurs. MariaDB exige des `/` dans les chemins, et le dossier ne doit pas être synchronisé par OneDrive : le service MariaDB n'y a pas accès.

---

## ✅ Qualité des données : contrôles et corrections

| Anomalie détectée | Volume | Traitement |
|---|---|---|
| Année de sortie absente (`N/A`) | 271 jeux (270 après corrections) | Conservés : leurs ventes comptent dans les totaux, mais ils sont exclus des analyses par année (libellé « Année inconnue » dans les filtres) |
| Éditeur absent | 58 jeux | Conservés, `NULL` |
| Doublons nom + plateforme + année | 2 | *Madden NFL 13 (PS3)* fusionné (ventes additionnées), *Metroid* en double supprimé |
| Jeux datés après 2016 | 4 | Exclus de la vue `v_ventes` (années incomplètes) |
| Année 2016 incomplète | – | Signalée par une annotation dans le graphique |
| Studios sans libellé (identifiant `Q123…` affiché à la place du nom) | 268 | Renommés « (nom inconnu) », mais conservés sur la carte |
| Studios homonymes | 8 | Conservés (entités Wikidata distinctes) ; la carte utilise l'`id` |
| Studios sans pays | 366 | Visibles sur la carte, exclus du Top 10 des pays |
| Concepteurs « nés en 2000 » (date imprécise « XXᵉ siècle » codée 2000 par Wikidata) | 20 | Année remplacée par `NULL` |

**Bilan pour la table des ventes :**

| Indicateur | Avant | Après |
|---|---|---|
| Lignes de la table `ventes` | 16 598 | 16 596 |
| Lignes de la vue `v_ventes` | 16 594 | 16 592 |
| Doublons | 2 | 0 |
| Ventes mondiales totales (M) | 8 920,44 | 8 920,42 |

---

## 🔌 Connexion ODBC

1. Installer le pilote **MySQL Connector/ODBC 64 bits** (version Unicode).
2. Ouvrir **Sources de données ODBC (64 bits)**, onglet **DSN système**, puis **Ajouter** :
   - Data Source Name : `jeux_video_dsn`
   - TCP/IP Server : `localhost`, port `3306`
   - User / Password : **compte MariaDB local, non publié dans ce dépôt**
   - Database : `jeux_video`
   - Cliquer sur **Test** : « Connection successful ».
3. Dans Tableau Desktop, choisir **Se connecter → Autres bases de données (ODBC)**, puis le DSN `jeux_video_dsn`, la base `jeux_video` et les tables ou vues.

🔒 **Aucun identifiant ni mot de passe n'est publié dans ce dépôt.** Le fichier de configuration de VS Code (`.vscode/settings.json`), qui contient les paramètres de connexion SQLTools, est exclu par le `.gitignore`.

Le classeur `.twbx` contient des **extraits** des données. Il s'ouvre donc sans la base MariaDB ni le DSN.

---

## 📊 Tableaux de bord

### 1. Ventes : *Quels jeux, genres et plateformes se vendent le plus ?*
![Dashboard Ventes](captures/dashboard_1.png)

- **Objectif :** identifier les genres et les plateformes qui dominent le marché, globalement et par région.
- **Public :** éditeurs et responsables marketing.
- **Indicateurs (KPI) :** 8 920 M de ventes, 578 éditeurs, 11 490 jeux, 31 plateformes.
- **Visualisations :** barres verticales (genres), barres horizontales (Top 10 des plateformes), courbe (ventes selon l'année de sortie).
- **Filtres et interactions :** paramètre **Région** (Monde, Amérique du Nord, Europe, Japon, Autres) qui recalcule tous les graphiques et les titres ; filtre **Décennie de sortie**.
- **Interprétation :** Action, Sports et Shooter représentent 46 % des ventes mondiales. La PS2 est la plateforme la plus vendue (1 256 M), et Sony place 5 consoles dans le Top 10. Le Japon se distingue : le RPG y domine (27 % des ventes) et la DS est n°1. Les ventes culminent pour les jeux sortis en 2008-2009.

### 2. Studios : *Où se créent les jeux vidéo dans le monde ?*
![Dashboard Studios](captures/dashboard_2.png)

- **Objectif :** cartographier les studios de jeux vidéo et leur concentration géographique.
- **Public :** étudiants, acteurs de l'emploi et de l'attractivité régionale.
- **Indicateurs (KPI) :** 4 439 studios, 82 pays, 62 % créés depuis 2000.
- **Visualisations :** carte à points (ville du siège), barres (Top 10 des pays), aire (créations par décennie).
- **Filtres et interactions :** un clic sur un pays du Top 10 filtre la carte, la chronologie et les KPI. La France est mise en évidence en couleur.
- **Interprétation :** les États-Unis, le Japon et le Royaume-Uni concentrent 51 % des studios. La France est 5ᵉ (192 studios). Le pic de créations a lieu dans les années 2000 (1 182 studios). La décennie 2020 est incomplète.

### 3. Concepteurs : *Les femmes sont-elles représentées parmi les créateurs de jeux vidéo ?*
![Dashboard Concepteurs](captures/dashboard_3.png)

- **Objectif :** mesurer la place des femmes parmi les concepteurs de jeux.
- **Public :** écoles, entreprises du secteur, associations pour la diversité.
- **Indicateurs (KPI) :** 898 concepteurs, 6,8 % de femmes (sur les 876 dont le sexe est connu), 38 pays.
- **Visualisations :** barres avec ligne de moyenne (par pays), barres (créatrices les plus prolifiques), courbe avec points (par génération).
- **Filtres et interactions :** un clic sur un pays affiche ses créatrices.
- **Seuils de fiabilité :** au moins 15 concepteurs par pays, au moins 20 par génération, au moins 3 jeux par créatrice.
- **Interprétation :** la part de femmes passe de 2,4 % (génération 1940) à 7,9 % (génération 1980) : la progression est réelle mais lente. Le Canada est en tête (13 %), le Royaume-Uni en retrait (3,2 %). Muriel Tramis (France) est la créatrice la plus prolifique, avec 11 jeux.

### 4. Analyses statistiques : *Que révèlent les modèles statistiques sur le marché ?*
![Dashboard Analyses statistiques](captures/dashboard_4.png)

- **Objectif :** dépasser la description en testant une relation (régression) et en regroupant automatiquement les plateformes (clustering).
- **Public :** analystes et jury.
- **Filtres et interactions :** un clic sur une console du clustering filtre la régression sur les éditeurs de cette console.
- **Interprétation :** voir la section suivante.

---

## 📈 Analyses statistiques

Les deux modèles sont calculés avec les fonctions d'analyse de Tableau Desktop. Le détail complet se trouve dans `analyses/regression.txt` et `analyses/clustering.txt`.

### Régression linéaire : ventes totales en fonction du nombre de jeux publiés (579 éditeurs)
| Résultat | Valeur |
|---|---|
| R² | 0,64 |
| Pente | 0,71 M de ventes par jeu publié (p < 0,0001) |
| Ordonnée à l'origine | −4,94 (p = 0,063, non significative) |

➡️ Le nombre de jeux explique 64 % des écarts de ventes entre éditeurs. **Nintendo** est très au-dessus de la droite : environ 1 786 M vendus pour environ 700 jeux, alors que le modèle en prédit environ 490 M. Sa stratégie des hits l'emporte sur le volume.

### Clustering k-means : profils de consoles selon la part de leurs ventes par région (31 plateformes, 4 groupes)
| Groupe | Consoles | Profil |
|---|---|---|
| Consoles mondiales | PS, PS2, PS3, PS4, PC, Wii, X360, XOne… | Amérique du Nord 47 %, Europe 34 % |
| Consoles américaines | GBA, N64, GC, GEN, XB, 2600 | Amérique du Nord 70 % |
| Forte audience japonaise | NES, SNES, GB, DS, 3DS, PSP, PSV, DC… | Amérique du Nord 39 %, Japon 37 % |
| Exclusivités japonaises | SAT et consoles sorties uniquement au Japon | Japon 99 % |

➡️ 90 % de la variance est expliquée. Le profil d'une console ne dépend **pas de sa marque** : Nintendo apparaît dans 3 groupes. Les consoles portables sont plus tournées vers le Japon que les consoles de salon.

---

## ⚠️ Limites

- **Ventes physiques uniquement**, données arrêtées fin 2016 : les ventes numériques et les jeux mobiles ne sont pas pris en compte. C'est pourquoi aucune évolution récente n'est présentée.
- La courbe du dashboard 1 montre les ventes **cumulées des jeux selon leur année de sortie**, et non des ventes annuelles.
- Les données Wikidata sont **collaboratives** : la couverture est inégale selon les pays, et certaines informations manquent (366 studios sans pays, 22 concepteurs sans sexe renseigné).
- La liste des concepteurs ne couvre que les personnes reliées à un jeu par la propriété *conçu par* : c'est un échantillon, pas un recensement complet de la profession.

---

*Projet réalisé par [Votre nom] – Formation AJC – Novembre 2026*
