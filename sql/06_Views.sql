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