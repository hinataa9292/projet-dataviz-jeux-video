-- =====================================================
-- 03b - Corrections des anomalies détectées par 03_controle_qualite.sql
-- À lancer après les imports (02_import.sql, 05_studios.sql, 06_createurs_de_jeux.sql)
-- Script protégé : peut être relancé sans risque de double correction
-- =====================================================

-- Cas 1 : Madden NFL 13 (PS3, 2012) - ligne fragmentée (id 16128 = 0,01 M EU)
-- -> on fusionne ses ventes dans la ligne principale (id 604), puis on la supprime
-- (la fusion ne s'applique que si le fragment existe encore, pour éviter un double ajout)
UPDATE jeux_video.ventes
SET ventes_eu    = ventes_eu + 0.01,
    ventes_monde = ventes_monde + 0.01
WHERE id = 604
  AND (SELECT COUNT(*) FROM (SELECT id FROM jeux_video.ventes WHERE id = 16128) t) > 0;

DELETE FROM jeux_video.ventes WHERE id = 16128;

-- Cas 2 : Wii de Asobu: Metroid Prime (Wii) - doublon strictement identique
-- -> on supprime la seconde occurrence
DELETE FROM jeux_video.ventes WHERE id = 15000;

-- Vérification : le contrôle 5a doit maintenant être vide
SELECT nom, plateforme, annee, COUNT(*) AS nb
FROM jeux_video.ventes
GROUP BY nom, plateforme, annee
HAVING COUNT(*) > 1;


-- Cas 3 : studios sans nom (contrôle 6d : 268 studios)
-- Wikidata renvoie l'identifiant (ex. "Q615181") quand la fiche n'a pas de nom
-- en français ni en anglais -> on le remplace par un libellé lisible.
-- L'identifiant reste consultable dans la colonne wikidata_url.
UPDATE jeux_video.studios
SET nom = '(nom inconnu)'
WHERE nom REGEXP '^Q[0-9]+$';

-- Vérification : doit renvoyer 0
SELECT COUNT(*) AS nb_sans_nom
FROM jeux_video.studios
WHERE nom REGEXP '^Q[0-9]+$';


-- Cas 4 : concepteurs "nés en 2000" (20 personnes)
-- Wikidata stocke une date imprécise "XXe siècle" sous la forme 2000.
-- Ex. : Bruce Shelley (né en 1948), Tim Willits (1971) apparaissent "nés en 2000".
-- -> année inconnue (NULL). La décennie de naissance se recalcule automatiquement.
UPDATE jeux_video.createurs_de_jeux
SET annee_naissance = NULL
WHERE annee_naissance = 2000;

-- Vérification : doit renvoyer 0
SELECT COUNT(*) AS nb_nes_en_2000
FROM jeux_video.createurs_de_jeux
WHERE annee_naissance = 2000;