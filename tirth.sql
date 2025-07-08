-- -- Création de la base
-- CREATE DATABASE Gestion_Bibliotheque_Numerique_db;
-- \c  Gestion_Bibliotheque_Numerique_db


-- Création des tables

CREATE TABLE Utilisateurs (
    id_utilisateur SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(20) CHECK (role IN ('lecteur', 'bibliothecaire', 'admin'))
);

CREATE TABLE Livre (
    id_livre SERIAL PRIMARY KEY,
    titre VARCHAR(200),
    auteur VARCHAR(100),
    categorie VARCHAR(50),
    disponible BOOLEAN
);

CREATE TABLE Emprunts (
    id_emprunts SERIAL PRIMARY KEY,
    id_utilisateur INT REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE,
    id_livre INT REFERENCES Livre(id_livre) ON DELETE CASCADE,
    date_emprunt DATE,
    date_retour_prevue DATE,
    date_retour_reelle DATE
);

CREATE TABLE Commentaires (
    id_commentaire SERIAL PRIMARY KEY,
    id_utilisateur INT REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE,
    id_livre INT REFERENCES Livre(id_livre) ON DELETE CASCADE,
    texte TEXT,
    note INT CHECK (note >= 1 AND note <= 5)
);

-- Insertion des données fournies

INSERT INTO Utilisateurs (nom, email, role) VALUES
('Alice Martin', 'alice.martin@mail.com', 'lecteur'),
('John Doe', 'john.doe@mail.com', 'bibliothecaire'),
('Sarah Lopez', 'sarah.lopez@mail.com', 'lecteur'),
('Marc Dupont', 'marc.dupont@mail.com', 'admin'),
('Emma Bernard', 'emma.bernard@mail.com', 'bibliothecaire'),
('Thomas Durand', 'thomas.durand@mail.com', 'lecteur');

INSERT INTO Livre (titre, auteur, categorie, disponible) VALUES
('L''Étranger', 'Albert Camus', 'Roman', TRUE),
('1984', 'George Orwell', 'Science-fiction', FALSE),
('Le Petit Prince', 'Antoine de Saint-Ex.', 'Conte', TRUE),
('Dune', 'Frank Herbert', 'Science-fiction', FALSE),
('Les Misérables', 'Victor Hugo', 'Classique', TRUE),
('Sapiens', 'Yuval Noah Harari', 'Histoire', TRUE);

INSERT INTO Emprunts (id_utilisateur, id_livre, date_emprunt, date_retour_prevue, date_retour_reelle) VALUES
(1, 2, '2024-06-01', '2024-06-15', NULL),
(3, 4, '2024-06-20', '2024-07-05', '2024-07-03'),
(6, 2, '2024-05-10', '2024-05-25', '2024-05-24'),
(1, 4, '2024-07-01', '2024-07-15', NULL);

INSERT INTO Commentaires (id_utilisateur, id_livre, texte, note) VALUES
(1, 2, 'Un classique à lire absolument', 5),
(3, 4, 'Très dense, mais fascinant', 4),
(6, 2, 'Excellent, mais un peu long', 4),
(1, 4, 'Très bon roman de SF', 5),
(3, 1, 'Lecture facile et intéressante', 3);

-- 1. Lister tous les livres disponibles
SELECT * FROM Livre WHERE disponible = TRUE;

-- 2. Afficher les utilisateurs ayant le rôle ‘bibliothecaire’
SELECT * FROM Utilisateurs WHERE role = 'bibliothecaire';

-- 3. Trouver tous les emprunts en retard (date_retour_reelle est NULL et date_retour_prevue < aujourd'hui)
SELECT * FROM Emprunts
WHERE date_retour_reelle IS NULL AND date_retour_prevue < CURRENT_DATE;

-- 4. Donner le nombre total d’emprunts effectués
SELECT COUNT(*) AS total_emprunts FROM Emprunts;

-- 5. Afficher les 5 derniers commentaires publiés avec le nom de l'utilisateur et le titre du livre
SELECT c.id_commentaire, u.nom, l.titre, c.texte, c.note
FROM Commentaires c
JOIN Utilisateurs u ON c.id_utilisateur = u.id_utilisateur
JOIN Livre l ON c.id_livre = l.id_livre
ORDER BY c.id_commentaire DESC
LIMIT 5;

-- PARTIE 2 : REQUÊTES AVANCÉES

-- 1. Pour chaque utilisateur, afficher le nombre de livres qu’il a empruntés
SELECT u.id_utilisateur, u.nom, COUNT(e.id_emprunts) AS nb_emprunts
FROM Utilisateurs u
LEFT JOIN Emprunts e ON u.id_utilisateur = e.id_utilisateur
GROUP BY u.id_utilisateur, u.nom
ORDER BY nb_emprunts DESC;

-- 2. Afficher les livres jamais empruntés
SELECT l.*
FROM Livre l
LEFT JOIN Emprunts e ON l.id_livre = e.id_livre
WHERE e.id_emprunts IS NULL;

-- 3. Calculer la durée moyenne de prêt par livre (en jours)
SELECT l.id_livre, l.titre, AVG(EXTRACT(DAY FROM (e.date_retour_reelle - e.date_emprunt))) AS duree_moyenne_pret
FROM Livre l
JOIN Emprunts e ON l.id_livre = e.id_livre
WHERE e.date_retour_reelle IS NOT NULL
GROUP BY l.id_livre, l.titre;

-- 4. Lister les 3 livres les mieux notés (moyenne des notes)
SELECT l.id_livre, l.titre, AVG(c.note) AS note_moyenne
FROM Livre l
JOIN Commentaires c ON l.id_livre = c.id_livre
GROUP BY l.id_livre, l.titre
ORDER BY note_moyenne DESC
LIMIT 3;

-- 5. Afficher les utilisateurs qui ont emprunté au moins un livre de la catégorie "Science-fiction"
SELECT DISTINCT u.id_utilisateur, u.nom
FROM Utilisateurs u
JOIN Emprunts e ON u.id_utilisateur = e.id_utilisateur
JOIN Livre l ON e.id_livre = l.id_livre
WHERE l.categorie = 'Science-fiction';

-- PARTIE 3 : MISES À JOUR & TRANSACTIONS

-- 1. Mettre à jour le champ disponible à FALSE pour tous les livres actuellement empruntés (emprunts non retournés)
UPDATE Livre
SET disponible = FALSE
WHERE id_livre IN (
    SELECT id_livre FROM Emprunts WHERE date_retour_reelle IS NULL
);

-- 2. Transaction SQL pour emprunter un livre
BEGIN;

-- Vérifier que le livre est disponible
DO $$
DECLARE
    livre_disponible BOOLEAN;
BEGIN
    SELECT disponible INTO livre_disponible FROM Livre WHERE id_livre = 1; -- remplacer 1 par l'id du livre
    IF NOT livre_disponible THEN
        RAISE EXCEPTION 'Le livre n''est pas disponible.';
    END IF;
END $$;

-- Insérer un nouvel emprunt (remplacer id_utilisateur, id_livre, dates)
INSERT INTO Emprunts (id_utilisateur, id_livre, date_emprunt, date_retour_prevue, date_retour_reelle)
VALUES (1, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', NULL);

-- Mettre à jour le statut du livre à indisponible
UPDATE Livre SET disponible = FALSE WHERE id_livre = 1;

COMMIT;

-- 3. Supprimer tous les commentaires des utilisateurs inactifs (ceux qui n’ont jamais emprunté de livre)
DELETE FROM Commentaires
WHERE id_utilisateur IN (
    SELECT u.id_utilisateur
    FROM Utilisateurs u
    LEFT JOIN Emprunts e ON u.id_utilisateur = e.id_utilisateur
    WHERE e.id_emprunts IS NULL
);

-- PARTIE 4 : VUES ET FONCTIONS SQL

-- 1. Créer une vue Vue_Emprunts_Actifs qui affiche tous les emprunts en cours (sans retour)
CREATE OR REPLACE VIEW Vue_Emprunts_Actifs AS
SELECT e.*, u.nom AS nom_utilisateur, l.titre AS titre_livre
FROM Emprunts e
JOIN Utilisateurs u ON e.id_utilisateur = u.id_utilisateur
JOIN Livre l ON e.id_livre = l.id_livre
WHERE e.date_retour_reelle IS NULL;

-- 2. Créer une fonction nb_emprunts_utilisateur(id_utilisateur INT) qui retourne le nombre d’emprunts effectués par un utilisateur donné
CREATE OR REPLACE FUNCTION nb_emprunts_utilisateur(uid INT)
RETURNS INT AS $$
DECLARE
    nb INT;
BEGIN
    SELECT COUNT(*) INTO nb FROM Emprunts WHERE id_utilisateur = uid;
    RETURN nb;
END;
$$ LANGUAGE plpgsql;

-- Exemple d'utilisation :
SELECT nb_emprunts_utilisateur(1);
