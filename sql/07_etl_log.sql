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