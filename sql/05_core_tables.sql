-- 05 Core_Tables

-- Delete tables if they exist (correct order by Foreign Keys)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    country VARCHAR(50)
);

INSERT INTO customers
(
    customer_id,
    customer_name,
    email,
    country
)
SELECT
    MIN(customer_id),
    customer_name,
    email,
    country
FROM stg_customers
GROUP BY
    customer_name,
    email,
    country;

-- Validation
SELECT *
FROM customers;

-- Products
CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO products
(
    product_id,
    product_name,
    category,
    price
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM raw_products;

-- Validation
SELECT *
FROM products;

-- Orders
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

INSERT INTO orders
(
    order_id,
    customer_id,
    order_date
)
SELECT
    order_id,
    customer_id,
    order_date
FROM raw_orders;

-- Validation
SELECT *
FROM orders;

-- Order Items
CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

INSERT INTO order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity
)
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity
FROM raw_order_items;

-- Validation
SELECT *
FROM order_items;

-- Data Quality Validations

-- Total loaded clients
SELECT COUNT(*) AS total_customers
FROM customers;

-- Check orders without client
SELECT *
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check duplicate emails
SELECT
    email,
    COUNT(*) AS total
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Check sales by customer
SELECT
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_sales
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;