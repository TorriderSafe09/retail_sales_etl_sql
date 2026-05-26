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