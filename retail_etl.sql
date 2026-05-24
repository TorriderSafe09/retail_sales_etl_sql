CREATE DATABASE retail_etl;

USE retail_etl;

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

CREATE TABLE stg_customers AS
SELECT *
FROM raw_customers;

SELECT *
FROM raw_customers;

UPDATE stg_customers
SET customer_name = TRIM(customer_name);

SELECT *
FROM stg_customers;

UPDATE stg_customers
SET email = 'unknown@gmail.com'
WHERE email IS NULL;

SELECT * 
FROM stg_customers;

SELECT 
	email,
    COUNT(*) AS total
FROM stg_customers
GROUP BY email
HAVING COUNT(*) > 1;

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
GROUP BY p.product_name
ORDER BY units_sold DESC;

SELECT *
FROM vw_top_products;

CREATE TABLE etl_log(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(100),
    execution_date DATETIME,
    rows_processed INT,
    status VARCHAR(20)
);

INSERT INTO etl_log 
(
	process_name,
    execution_date,
    rows_processed,
    status
)
VALUES
(
	'Customer load',
    NOW(),
    (SELECT COUNT(*) FROM customers),
    'SUCCESS'
);

INSERT INTO etl_log
(
	process_name,
    execution_date,
    rows_processed,
    status
)
VALUES
(
	'Product load',
    NOW(),
    (SELECT COUNT(*) FROM products),
    'SUCCESS'
);

SELECT * 
FROM etl_log
ORDER BY execution_date DESC;

DELIMITER $$

CREATE PROCEDURE sp_customer_count()
BEGIN

	SELECT COUNT(*) AS total_customers
    FROM customers;
    
END $$

DELIMITER ;

CALL sp_customer_count();

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

SELECT *
FROM etl_log;

DELIMITER $$

CREATE PROCEDURE sp_customer_count()
BEGIN

	SELECT COUNT(*) AS total_customers
    FROM customers;
    
END $$

DELIMITER ;

CALL sp_customer_count();

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
    