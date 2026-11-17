# 🎮 Data visualisation – Le marché mondial du jeu vidéo

TP Data Visualisation – Open Data (formation AJC).

**Chaîne de traitement :** Open Data → import SQL → MariaDB → ODBC → Tableau Desktop → Story

## Sources de données
- **Ventes de jeux vidéo** : [Kaggle – Video Game Sales](https://www.kaggle.com/datasets/gregorut/videogamesales) (16 598 jeux, ventes jusqu'en 2016)
- **Studios de jeux vidéo** : Wikidata, requête SPARQL (4 439 studios géolocalisés)
- **Concepteurs de jeux vidéo** : Wikidata, requête SPARQL (898 personnes)

## Outils
MariaDB 10.6 · VS Code + SQLTools · pilote ODBC MySQL 64 bits · Tableau Desktop

## Contenu du dépôt
| Dossier | Contenu |
|---|---|
| `data/` | Fichiers CSV sources |
| `sql/` | Scripts SQL (création, import, contrôle qualité, corrections, vues) et requêtes SPARQL |
| `analyses/` | Résultats de la régression et du clustering |
| `visualisation/` | Classeur Tableau `.twbx` (données incluses) |
| `captures/` | Captures des 4 dashboards |
| `presentation/` | Story exportée en PDF et support de présentation |

## Exécution des scripts SQL
`01` → `02` → `05` → `06` → `03` (contrôles) → `03bis` (corrections) → `04` (vue pour Tableau)

## Connexion
DSN système ODBC `jeux_video_dsn` (localhost:3306, base `jeux_video`), puis dans Tableau : **Autres bases de données (ODBC)**.
🔒 Aucun identifiant ni mot de passe n'est publié dans ce dépôt.

## Tableaux de bord
1. **Ventes** : quels jeux, genres et plateformes se vendent le plus ?
2. **Studios** : où se créent les jeux vidéo dans le monde ?
3. **Concepteurs** : les femmes sont-elles représentées parmi les créateurs de jeux ?
4. **Analyses statistiques** : régression linéaire (éditeurs) et clustering k-means (plateformes)

## Limites
Ventes physiques uniquement, arrêtées fin 2016. Les données Wikidata sont collaboratives et incomplètes.