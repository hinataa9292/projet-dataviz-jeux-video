CREATE DATABASE jeux_video CHARACTER SET utf8mb4;

CREATE TABLE jeux_video.ventes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rang INT,
  nom VARCHAR(255),
  plateforme VARCHAR(20),
  annee SMALLINT NULL,
  genre VARCHAR(30),
  editeur VARCHAR(100),
  ventes_na DECIMAL(6,2),
  ventes_eu DECIMAL(6,2),
  ventes_jp DECIMAL(6,2),
  ventes_autres DECIMAL(6,2),
  ventes_monde DECIMAL(6,2)
);
