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