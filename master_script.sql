-- 01 Create_Database

CREATE DATABASE IF NOT EXISTS retail_etl;

USE retail_etl;

-- Disable safe updates for staging data cleansing
SET SQL_SAFE_UPDATES = 0;

-- Validation
SELECT DATABASE();

-- 02 Raw_Tables

CREATE TABLE IF NOT EXISTS raw_customers(
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    country VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS raw_products(
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS raw_orders(
    order_id INT,
    customer_id INT,
    order_date DATE
);

CREATE TABLE IF NOT EXISTS raw_order_items(
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT
);

-- Validation
SHOW TABLES;

-- 03 Load_Raw_Data

INSERT INTO raw_customers
(
    customer_id,
    customer_name,
    email,
    country
)VALUES
(1,'Juan Perez','juan@gmail.com','Mexico'),
(2,' María Lopez ','maría@gmail.com','Mexico'),
(3,'Pedro García','pedro@gmail.com','Canada'),
(4,'Juan Perez','juan@gmail.com','Mexico'),
(5,'Ana Torres',NULL,'USA');

INSERT INTO raw_products
(
    product_id,
    product_name,
    category,
    price
)
VALUES
(101,'Laptop','Technology',25000),
(102,'Mouse','Technology',500),
(103,'Keyboard','Technology',1200),
(104,'Monitor','Technology',4500);

INSERT INTO raw_orders
(
    order_id,
    customer_id,
    order_date
)
VALUES
(1001,1,'2025-01-10'),
(1002,2,'2025-01-11'),
(1003,3,'2025-01-12'),
(1004,5,'2025-01-13');

INSERT INTO raw_order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity
)
VALUES
(1,1001,101,1),
(2,1001,102,2),
(3,1002,103,1),
(4,1003,104,2),
(5,1004,102,5);

-- Validation
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_products;
SELECT COUNT(*) FROM raw_orders;
SELECT COUNT(*) FROM raw_order_items;

SELECT *
FROM raw_customers;

-- 04 Staging

DROP TABLE IF EXISTS stg_customers;

CREATE TABLE stg_customers AS
SELECT *
FROM raw_customers;

UPDATE stg_customers
SET customer_name = TRIM(customer_name);

UPDATE stg_customers
SET email = 'unknown@example.com'
WHERE email IS NULL;

-- Validations
SELECT *
FROM stg_customers;

SELECT COUNT(*)
FROM stg_customers;

SELECT COUNT(*)
FROM stg_customers
WHERE email IS NULL;

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
SELECT COUNT(*)
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
SELECT COUNT(*)
FROM vw_sales_by_country;

CREATE VIEW vw_top_products AS
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(p.price * oi.quantity) AS total_revenue
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

DROP TABLE IF EXISTS etl_log;

CREATE TABLE etl_log(
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(100) NOT NULL,
    execution_date DATETIME NOT NULL,
    rows_processed INT NOT NULL,
    status VARCHAR(20) NOT NULL
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

-- 09 Triggers_Audit

DROP TRIGGER IF EXISTS trg_customer_insert;
DROP TRIGGER IF EXISTS trg_customer_update;
DROP TRIGGER IF EXISTS trg_validate_quantity;

DROP TABLE IF EXISTS audit_customer_updates;
DROP TABLE IF EXISTS audit_customers;

-- Audit table for customer insertions

CREATE TABLE audit_customers(
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_date DATETIME NOT NULL
);

-- Validation
DESCRIBE audit_customers;

-- Trigger: Audit of new clients

DELIMITER $$

CREATE TRIGGER trg_customer_insert
AFTER INSERT
ON customers
FOR EACH ROW
BEGIN

    INSERT INTO audit_customers
    (
        customer_id,
        action_type,
        action_date
    )
    VALUES
    (
        NEW.customer_id,
        'INSERT',
        NOW()
    );

END $$

DELIMITER ;

-- Validation
SHOW TRIGGERS;

-- In case it already exists, clear records before testing
DELETE FROM customers
WHERE customer_id IN (99,100);

-- Test
INSERT INTO customers
(
    customer_id,
    customer_name,
    email,
    country
)
VALUES
(
    99,
    'Test Customer',
    'testcustomer@gmail.com',
    'Mexico'
);

-- Verification
SELECT *
FROM audit_customers;

-- Second test
INSERT INTO customers
(
    customer_id,
    customer_name,
    email,
    country
)
VALUES
(
    100,
    'Audit Test',
    'audittest@gmail.com',
    'Canada'
);

-- Verification
SELECT *
FROM audit_customers
ORDER BY audit_id DESC;

SELECT COUNT(*)
FROM audit_customers;

-- Audit table for updates

CREATE TABLE audit_customer_updates(
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    old_name VARCHAR(100),
    new_name VARCHAR(100),
    update_date DATETIME NOT NULL
);

-- Validation
DESCRIBE audit_customer_updates;

-- Trigger: Name change audit

DELIMITER $$

CREATE TRIGGER trg_customer_update
AFTER UPDATE
ON customers
FOR EACH ROW
BEGIN

    IF OLD.customer_name <> NEW.customer_name THEN

        INSERT INTO audit_customer_updates
        (
            customer_id,
            old_name,
            new_name,
            update_date
        )
        VALUES
        (
            OLD.customer_id,
            OLD.customer_name,
            NEW.customer_name,
            NOW()
        );

    END IF;

END $$

DELIMITER ;

-- Test
UPDATE customers
SET customer_name = 'Paco Torres'
WHERE customer_id = 1;

-- Verification
SELECT *
FROM audit_customer_updates;

-- Trigger: Product quantity validation

DELIMITER $$

CREATE TRIGGER trg_validate_quantity
BEFORE INSERT
ON order_items
FOR EACH ROW
BEGIN

    IF NEW.quantity <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';

    END IF;

END $$

DELIMITER ;

-- Validation
SHOW TRIGGERS;

-- Valid test
INSERT INTO order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity
)
VALUES
(
    99,
    1001,
    101,
    1
);

-- Verification
SELECT *
FROM order_items
WHERE order_item_id = 99;

-- Invalid test
INSERT INTO order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity
)
VALUES
(
    100,
    1001,
    101,
    -5
);

-- Final verification
SELECT *
FROM order_items
WHERE order_item_id = 100;