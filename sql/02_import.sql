TRUNCATE TABLE jeux_video.ventes;

LOAD DATA INFILE 'C:/projet_jv/vgsales.csv'
INTO TABLE jeux_video.ventes
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(rang, nom, plateforme, @annee, genre, @editeur,
 ventes_na, ventes_eu, ventes_jp, ventes_autres, @monde)
SET annee = NULLIF(@annee, 'N/A'),
    editeur = NULLIF(@editeur, 'N/A'),
    ventes_monde = TRIM(TRAILING '\r' FROM @monde);