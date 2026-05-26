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