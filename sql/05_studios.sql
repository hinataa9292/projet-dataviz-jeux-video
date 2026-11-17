-- Ménage : l'ancienne carte n'est plus utile
DROP VIEW IF EXISTS jeux_video.v_carte;
DROP TABLE IF EXISTS jeux_video.pays_region;

-- Nouvelle table des studios
CREATE TABLE IF NOT EXISTS jeux_video.studios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wikidata_url VARCHAR(100),
  nom VARCHAR(255),
  pays VARCHAR(100),
  ville VARCHAR(150),
  annee_creation SMALLINT NULL,
  latitude DECIMAL(9,6),
  longitude DECIMAL(9,6)
);



TRUNCATE TABLE jeux_video.studios;

LOAD DATA INFILE 'C:/projet_jv/studios.csv'
INTO TABLE jeux_video.studios
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(wikidata_url, nom, @pays, @ville, @annee, latitude, longitude, @coord)
SET pays = NULLIF(@pays, ''),
    ville = NULLIF(@ville, ''),
    annee_creation = IF(@annee BETWEEN 1850 AND 2026, @annee, NULL);



-- Colonne calculée : décennie de création (calcul fait par MariaDB,
-- car le pilote ODBC générique ne sait pas traduire FLOOR depuis Tableau)
ALTER TABLE jeux_video.studios
ADD COLUMN decennie_creation SMALLINT
AS (FLOOR(annee_creation / 10) * 10) PERSISTENT;