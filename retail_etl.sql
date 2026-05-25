-- 01 Create_Database
CREATE DATABASE IF NOT EXISTS retail_etl;

USE retail_etl;

SET SQL_SAFE_UPDATES = 0;

-- Validaciones
SELECT DATABASE ();

-- 02 Raw_Tables
CREATE TABLE raw_customers(
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    country VARCHAR(50)
);

CREATE TABLE raw_products(
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE raw_orders(
    order_id INT,
    customer_id INT,
    order_date DATE
);

CREATE TABLE raw_order_items(
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT
);

-- Validaciones 
SHOW TABLES;

-- 03 Load_Raw_Data
INSERT INTO raw_customers VALUES
(1,'Juan Perez','juan@gmail.com','Mexico'),
(2,' María Lopez ','maría@gmail.com','Mexico'),
(3,'Pedro García','pedro@gmail.com','Canada'),
(4,'Juan Perez','juan@gmail.com','Mexico'),
(5,'Ana Torres',NULL,'USA');

INSERT INTO raw_products VALUES
(101,'Laptop','Technology',25000),
(102,'Mouse','Technology',500),
(103,'Keyboard','Technology',1200),
(104,'Monitor','Technology',4500);

INSERT INTO raw_orders VALUES
(1001,1,'2025-01-10'),
(1002,2,'2025-01-11'),
(1003,3,'2025-01-12'),
(1004,5,'2025-01-13');

INSERT INTO raw_order_items VALUES
(1,1001,101,1),
(2,1001,102,2),
(3,1002,103,1),
(4,1003,104,2),
(5,1004,102,5);

-- Validaciones
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_products;
SELECT COUNT(*) FROM raw_orders;
SELECT COUNT(*) FROM raw_order_items;

-- 04 Staging
CREATE TABLE stg_customers AS
SELECT *
FROM raw_customers;

UPDATE stg_customers
SET customer_name = TRIM(customer_name);

UPDATE stg_customers
SET email = 'unknown@gmail.com'
WHERE email IS NULL;

-- Validaciones
SELECT *
FROM stg_customers;
SELECT COUNT(*)
FROM stg_customers;
SELECT COUNT(*)
FROM stg_customers
WHERE email IS NULL;

-- 05 Core_Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    country VARCHAR(50)
);

INSERT INTO customers
SELECT
    MIN(customer_id),
    customer_name,
    email,
    country
FROM stg_customers
GROUP BY customer_name,email,country;

SELECT *
FROM customers;

CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products
SELECT *
FROM raw_products;

SELECT *
FROM products;

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

INSERT INTO orders
SELECT *
FROM raw_orders;

SELECT *
FROM orders;

CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

INSERT INTO order_items
SELECT *
FROM raw_order_items;

SELECT *
FROM order_items;

-- Validaciones
SELECT COUNT(*)
FROM customers;
SELECT *
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
SELECT
    email,
    COUNT(*) AS total
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;
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

-- 06 Views
DROP VIEW IF EXISTS vw_sales_by_customer;
DROP VIEW IF EXISTS vw_sales_by_country;
DROP VIEW IF EXISTS vw_top_products;

CREATE VIEW vw_sales_by_customer AS
SELECT
    c.customer_name,
    c.country,
    SUM(p.price * oi.quantity) AS total_sales
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_name,
    c.country;
    
SELECT *
FROM vw_sales_by_customer;

CREATE VIEW vw_sales_by_country AS
SELECT
    c.country,
    SUM(p.price * oi.quantity) AS total_sales
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.country;

SELECT *
FROM vw_sales_by_country;

CREATE VIEW vw_top_products AS
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name;

SELECT *
FROM vw_top_products
ORDER BY units_sold DESC;

-- Validaciones
SELECT *
FROM vw_sales_by_customer
ORDER BY total_sales DESC
LIMIT 1;
SELECT *
FROM vw_sales_by_country
ORDER BY total_sales DESC
LIMIT 1;
SELECT *
FROM vw_top_products
ORDER BY units_sold DESC
LIMIT 1;

-- 07 ETL_log
CREATE TABLE etl_log(
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(100),
    execution_date DATETIME,
    rows_processed INT,
    status VARCHAR(20)
);

-- Validaciones
SELECT COUNT(*)
FROM etl_log;
SELECT *
FROM etl_log
ORDER BY log_id DESC;
SELECT
    process_name,
    COUNT(*) AS executions
FROM etl_log
GROUP BY process_name;
SELECT *
FROM etl_log
ORDER BY log_id DESC
LIMIT 1;
SELECT
    process_name,
    execution_date,
    rows_processed,
    status
FROM etl_log
ORDER BY execution_date DESC;

-- 08 Stored_Procedures
DROP PROCEDURE IF EXISTS sp_customer_count;
DROP PROCEDURE IF EXISTS sp_sales_by_country;
DROP PROCEDURE IF EXISTS sp_log_customer_load;
DROP PROCEDURE IF EXISTS sp_load_new_customers;

DELIMITER $$

CREATE PROCEDURE sp_customer_count()
BEGIN

    SELECT COUNT(*) AS total_customers
    FROM customers;

END $$

DELIMITER ;

CALL sp_customer_count();

-- Validacion 
SELECT COUNT(*)
FROM customers;

DELIMITER $$

CREATE PROCEDURE sp_sales_by_country()
BEGIN

    SELECT
        country,
        total_sales
    FROM vw_sales_by_country
    ORDER BY total_sales DESC;

END $$

DELIMITER ;

CALL sp_sales_by_country();

-- Validacion
SELECT *
FROM vw_sales_by_country
ORDER BY total_sales DESC;

DELIMITER $$

CREATE PROCEDURE sp_log_customer_load()
BEGIN

    INSERT INTO etl_log
    (
        process_name,
        execution_date,
        rows_processed,
        status
    )
    VALUES
    (
        'Customer Load',
        NOW(),
        (SELECT COUNT(*) FROM customers),
        'SUCCESS'
    );

END $$

DELIMITER ;

CALL sp_log_customer_load();

-- Validacion
SELECT *
FROM etl_log
ORDER BY log_id DESC
LIMIT 1;

DELIMITER $$

CREATE PROCEDURE sp_load_new_customers()
BEGIN

    DECLARE rows_loaded INT;

    INSERT INTO customers
    (
        customer_id,
        customer_name,
        email,
        country
    )
    SELECT
        s.customer_id,
        s.customer_name,
        s.email,
        s.country
    FROM stg_customers s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM customers c
        WHERE c.email = s.email
    );

    SET rows_loaded = ROW_COUNT();

    INSERT INTO etl_log
    (
        process_name,
        execution_date,
        rows_processed,
        status
    )
    VALUES
    (
        'Incremental Customer Load',
        NOW(),
        rows_loaded,
        'SUCCESS'
    );

END $$

DELIMITER ;

CALL sp_load_new_customers();

-- Validacion
SELECT *
FROM etl_log
ORDER BY log_id DESC
LIMIT 1;

-- Validacion Final 
SHOW PROCEDURE STATUS
WHERE Db = 'retail_etl';

