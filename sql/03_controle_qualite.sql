-- 1. Aperçu des 10 premiers jeux
SELECT * FROM jeux_video.ventes LIMIT 10;

-- 2. Valeurs manquantes
SELECT
  SUM(annee IS NULL)   AS annees_vides,
  SUM(editeur IS NULL) AS editeurs_vides
FROM jeux_video.ventes;

-- 3. Période couverte
SELECT MIN(annee) AS premiere, MAX(annee) AS derniere
FROM jeux_video.ventes;

-- 4. Nombre de jeux par année (repérer les années trop peu remplies)
SELECT annee, COUNT(*) AS nb
FROM jeux_video.ventes
GROUP BY annee
ORDER BY annee DESC;


-- =====================================================
-- 5. DOUBLONS - table ventes
-- =====================================================

-- 5a. Un même jeu (nom + plateforme + année) présent plusieurs fois ?
SELECT nom, plateforme, annee, COUNT(*) AS nb
FROM jeux_video.ventes
GROUP BY nom, plateforme, annee
HAVING COUNT(*) > 1;

-- 5b. Le rang (identifiant de la source) est-il unique ?
SELECT rang, COUNT(*) AS nb
FROM jeux_video.ventes
GROUP BY rang
HAVING COUNT(*) > 1;

-- 5c. Cohérence : ventes monde = somme des régions ? (écart > 0,05 M)
SELECT nom, plateforme, ventes_monde,
       ventes_na + ventes_eu + ventes_jp + ventes_autres AS somme_regions
FROM jeux_video.ventes
WHERE ABS(ventes_monde - (ventes_na + ventes_eu + ventes_jp + ventes_autres)) > 0.05;

-- =====================================================
-- 6. DOUBLONS ET COORDONNÉES - table studios
-- =====================================================

-- 6a. Un même studio Wikidata présent plusieurs fois ?
SELECT wikidata_url, COUNT(*) AS nb
FROM jeux_video.studios
GROUP BY wikidata_url
HAVING COUNT(*) > 1;

-- 6b. Des studios différents qui portent le même nom ?
SELECT nom, COUNT(*) AS nb
FROM jeux_video.studios
GROUP BY nom
HAVING COUNT(*) > 1
ORDER BY nb DESC;

-- 6c. Coordonnées hors limites ou vides
SELECT nom, latitude, longitude
FROM jeux_video.studios
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180
   OR latitude IS NULL OR longitude IS NULL
   OR (latitude = 0 AND longitude = 0);


-- 6d. Studios sans nom (Wikidata renvoie l'identifiant "Q123..." à la place)
SELECT COUNT(*) AS nb_sans_nom
FROM jeux_video.studios
WHERE nom REGEXP '^Q[0-9]+$';