-- PARTIE B

-- Q4

-- 1FN : projets_liste contient plusieurs projets dans une cellule (non atomique).
--       On crée une ligne par couple (employé, projet). Clé : (employe_id, projet).
-- 2FN : employe_nom et dept_nom ne dépendent que de employe_id (partie de la clé), et
--       chef_projet que de projet (autre partie de la clé) : dépendances partielles.
--       On extrait les employés d'un côté, les projets de l'autre.
-- 3FN : chef_projet_tel dépend de chef_projet (attribut non-clé) : dépendance transitive
--       projet -> chef_projet -> chef_projet_tel. On extrait les chefs de projet.
--       (dept_nom est extrait dans departements pour éviter de répéter le nom.)

CREATE TABLE departements (
    dept_id  INT PRIMARY KEY,
    dept_nom VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employes_tp (
    employe_id  INT PRIMARY KEY,
    employe_nom VARCHAR(100) NOT NULL,
    dept_id     INT NOT NULL REFERENCES departements(dept_id)
);

CREATE TABLE chefs_projet (
    chef_id  INT PRIMARY KEY,
    chef_nom VARCHAR(100) NOT NULL,
    chef_tel VARCHAR(20)
);

CREATE TABLE projets (
    projet_id  INT PRIMARY KEY,
    projet_nom VARCHAR(100) NOT NULL,
    chef_id    INT NOT NULL REFERENCES chefs_projet(chef_id)
);

CREATE TABLE affectations (
    employe_id INT REFERENCES employes_tp(employe_id),
    projet_id  INT REFERENCES projets(projet_id),
    PRIMARY KEY (employe_id, projet_id)
);

-- Q5

WITH classement AS (
    SELECT cat.nom AS categorie,
           p.nom AS produit,
           p.prix_unitaire,
           DENSE_RANK() OVER (PARTITION BY p.categorie_id
                              ORDER BY p.prix_unitaire DESC) AS rang_prix
    FROM produits p
    JOIN categories cat ON cat.id = p.categorie_id
)
SELECT categorie, produit, prix_unitaire, rang_prix
FROM classement
WHERE rang_prix <= 2
ORDER BY categorie ASC, rang_prix ASC;

-- Q6

WITH RECURSIVE organigramme AS (
    SELECT id, nom, poste, departement,
           1 AS niveau,
           nom::TEXT AS chemin
    FROM employes
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.id, e.nom, e.poste, e.departement,
           o.niveau + 1,
           o.chemin || ' > ' || e.nom
    FROM employes e
    JOIN organigramme o ON e.manager_id = o.id
    WHERE o.niveau < 10
)
SELECT id, nom, poste, niveau, chemin
FROM organigramme
ORDER BY niveau ASC, id ASC;