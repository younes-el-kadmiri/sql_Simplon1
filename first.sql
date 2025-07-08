-- -- Création de la base
-- CREATE DATABASE store_db;
-- \c store_db  -- Se connecter à la base (équivalent de USE)

-- Création des tables
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(20)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10, 2),
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount NUMERIC(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insertion de données
INSERT INTO customers (first_name, last_name, email, phone_number) VALUES
('John', 'Doe', 'john.doe@gmail.com', '0612345678'),
('Alice', 'Smith', 'alice.smith@yahoo.com', '0623456789'),
('David', 'Dubois', 'david.dubois@live.com', '0634567890'),
('Maria', 'Gonzalez', 'maria.gon@gmail.com', '0645678901'),
('Karim', 'Dali', 'karim.dali@outlook.com', '0656789012');

INSERT INTO products (name, price, category) VALUES
('Laptop', 899.99, 'Electronics'),
('Smartphone', 599.50, 'Electronics'),
('Office Chair', 149.90, 'Furniture'),
('Coffee Maker', 79.99, 'Appliances'),
('USB-C Cable', 15.00, 'Accessories');

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-15', 914.99),
(3, '2024-03-02', 78.99),
(2, '2023-12-30', 149.90),
(1, '2024-04-18', 614.50),
(5, '2022-11-01', 79.99);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 5, 1),
(2, 4, 1),
(3, 3, 1),
(4, 2, 1),
(5, 4, 1);

-- Requêtes simples
SELECT * FROM customers;
SELECT * FROM orders WHERE order_date > '2024-01-01';
SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- Filtres avec WHERE
SELECT * FROM customers WHERE first_name = 'John';
SELECT * FROM orders WHERE total_amount > 100;
SELECT * FROM customers WHERE last_name LIKE 'D%';

-- Mise à jour
UPDATE customers SET phone_number = '0600000000' WHERE customer_id = 1;
UPDATE orders SET total_amount = total_amount * 1.10;
UPDATE customers SET email = 'john.doe@newmail.com' WHERE customer_id = 1;

-- Suppressions
DELETE FROM orders WHERE order_date < '2023-01-01';
DELETE FROM customers WHERE customer_id = 3;  -- Supprime aussi ses commandes via ON DELETE CASCADE
DELETE FROM orders WHERE customer_id = 1;
