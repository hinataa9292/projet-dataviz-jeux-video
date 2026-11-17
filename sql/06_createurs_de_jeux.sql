-- =====================================================
-- 06 - Concepteurs de jeux vidéo (game designers)
-- Source : Wikidata, propriété P287 "conçu par" - 898 personnes (requête du 16/11/2026)
-- =====================================================

CREATE TABLE IF NOT EXISTS jeux_video.createurs_de_jeux (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wikidata_url VARCHAR(100),
  nom VARCHAR(255),
  sexe VARCHAR(50),
  pays VARCHAR(100),
  annee_naissance SMALLINT NULL,
  nb_jeux INT
);

TRUNCATE TABLE jeux_video.createurs_de_jeux;

LOAD DATA INFILE 'C:/projet_jv/csv/createurs_de_jeux.csv'
INTO TABLE jeux_video.createurs_de_jeux
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(wikidata_url, nom, @sexe, @pays, @annee, @nb)
SET sexe = NULLIF(@sexe, ''),
    pays = NULLIF(@pays, ''),
    annee_naissance = IF(@annee BETWEEN 1900 AND 2015, @annee, NULL),
    nb_jeux = CAST(TRIM(TRAILING '\r' FROM @nb) AS UNSIGNED);

-- Décennie de naissance (calculée par MariaDB, car FLOOR n'est pas traduit par le pilote ODBC)
ALTER TABLE jeux_video.createurs_de_jeux
ADD COLUMN IF NOT EXISTS decennie_naissance SMALLINT
AS (FLOOR(annee_naissance / 10) * 10) PERSISTENT;


-- Vue pour Tableau : regroupement des sexes + indicateurs 1/0
-- (les indicateurs évitent les comparaisons de texte depuis Tableau,
--  source d'erreurs de collation avec le pilote ODBC)
CREATE OR REPLACE VIEW jeux_video.v_createurs AS
SELECT *,
  CASE
    WHEN sexe = 'masculin' THEN 'Hommes'
    WHEN sexe IN ('féminin', 'femme trans') THEN 'Femmes'
    WHEN sexe IS NULL THEN 'Non renseigné'
    ELSE 'Non-binaire'
  END AS sexe_regroupe,
  CASE WHEN sexe IN ('féminin', 'femme trans') THEN 1 ELSE 0 END AS est_femme,
  CASE WHEN sexe IS NULL THEN 0 ELSE 1 END AS sexe_connu
FROM jeux_video.createurs_de_jeux;

-- Vérification
SELECT sexe_regroupe, COUNT(*) AS nb
FROM jeux_video.v_createurs
GROUP BY sexe_regroupe
ORDER BY nb DESC;