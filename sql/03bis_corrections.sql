
UPDATE jeux_video.ventes
SET ventes_eu    = ventes_eu + 0.01,
    ventes_monde = ventes_monde + 0.01
WHERE id = 604
  AND (SELECT COUNT(*) FROM (SELECT id FROM jeux_video.ventes WHERE id = 16128) t) > 0;

DELETE FROM jeux_video.ventes WHERE id = 16128;


DELETE FROM jeux_video.ventes WHERE id = 15000;

SELECT nom, plateforme, annee, COUNT(*) AS nb
FROM jeux_video.ventes
GROUP BY nom, plateforme, annee
HAVING COUNT(*) > 1;



SET nom = '(nom inconnu)'
WHERE nom REGEXP '^Q[0-9]+$';


SELECT COUNT(*) AS nb_sans_nom
FROM jeux_video.studios
WHERE nom REGEXP '^Q[0-9]+$';


UPDATE jeux_video.createurs_de_jeux
SET annee_naissance = NULL
WHERE annee_naissance = 2000;


SELECT COUNT(*) AS nb_nes_en_2000
FROM jeux_video.createurs_de_jeux
WHERE annee_naissance = 2000;