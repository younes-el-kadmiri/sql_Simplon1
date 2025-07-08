-- Challenge 1 : Jointures entre Tables
SELECT o.order_id, o.order_date, o.total_amount, c.first_name, c.last_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) AS nb_commandes
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY nb_commandes DESC;

-- Challenge 2 : Agrégation de Données
SELECT SUM(total_amount) AS montant_total_commandes FROM orders;

SELECT COUNT(*) AS nombre_clients FROM customers;

SELECT AVG(total_amount) AS montant_moyen_commandes FROM orders;

-- Challenge 3 : Groupement de Données
SELECT customer_id, SUM(total_amount) AS total_commandes
FROM orders
GROUP BY customer_id
ORDER BY total_commandes DESC;

SELECT DATE_TRUNC('month', order_date) AS mois, COUNT(*) AS nb_commandes
FROM orders
GROUP BY mois
ORDER BY mois;

SELECT DATE_TRUNC('month', order_date) AS mois, AVG(total_amount) AS montant_moyen
FROM orders
GROUP BY mois
ORDER BY mois;

SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_commandes
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 1000;

-- Challenge 4 : Sous-Requêtes
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
WHERE c.customer_id IN (
    SELECT customer_id FROM orders WHERE total_amount > 200
);

SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_commandes
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_commandes DESC
LIMIT 1;

SELECT * FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- Challenge 5 : Création de Vues
CREATE OR REPLACE VIEW customer_orders_view AS
SELECT c.customer_id, c.first_name, c.last_name, o.order_id, o.order_date, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

SELECT customer_id, first_name, last_name, SUM(total_amount) AS total_commandes
FROM customer_orders_view
GROUP BY customer_id, first_name, last_name
HAVING SUM(total_amount) > 1000;

CREATE OR REPLACE VIEW monthly_sales_view AS
SELECT DATE_TRUNC('month', order_date) AS mois, SUM(total_amount) AS total_ventes
FROM orders
GROUP BY mois
ORDER BY mois;
