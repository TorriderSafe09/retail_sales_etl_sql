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