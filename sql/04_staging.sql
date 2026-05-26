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