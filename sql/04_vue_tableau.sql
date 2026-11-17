CREATE VIEW jeux_video.v_ventes AS
SELECT *,
       FLOOR(annee / 10) * 10 AS decennie
FROM jeux_video.ventes
WHERE annee IS NULL OR annee <= 2016;