-- 01 Create_Database

CREATE DATABASE IF NOT EXISTS retail_etl;

USE retail_etl;

-- Disable safe updates for staging data cleansing
SET SQL_SAFE_UPDATES = 0;

-- Validation
SELECT DATABASE();