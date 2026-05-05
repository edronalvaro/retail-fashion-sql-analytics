-- =====================================================
-- FASHION RETAIL PROJECT
-- DATA CLEANING PIPELINE
-- =====================================================

CREATE DATABASE retail_fashion;
USE retail_fashion;

/* =====================================================
   1. INITIAL DATA QUALITY CHECKS
===================================================== */

-- Null check (customers)
SELECT 
    ROUND(SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS pct_nulls
FROM sales;

-- Duplicate transaction check
SELECT 
    transaction_id,
    COUNT(*) AS count_duplicates
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;


/* =====================================================
   2. CREATE STAGING TABLES
===================================================== */

CREATE TABLE stg_customers LIKE customers;
INSERT INTO stg_customers SELECT * FROM customers;

CREATE TABLE stg_products LIKE products;
INSERT INTO stg_products SELECT * FROM products;

CREATE TABLE stg_sales LIKE sales;
INSERT INTO stg_sales SELECT * FROM sales;

CREATE TABLE stg_stores LIKE stores;
INSERT INTO stg_stores SELECT * FROM stores;


/* =====================================================
   3. CUSTOMER CLEANING
===================================================== */

START TRANSACTION;

-- Standardize gender values
UPDATE stg_customers
SET gender = LOWER(TRIM(gender));

UPDATE stg_customers
SET gender = 'unknown'
WHERE gender = '???';

-- Handle missing emails
UPDATE stg_customers
SET email = NULL
WHERE email IS NULL OR TRIM(email) = '';

-- Create age groups
ALTER TABLE stg_customers ADD age_group VARCHAR(20);

UPDATE stg_customers
SET age_group = CASE 
    WHEN age < 18 THEN 'Under 18'
    WHEN age BETWEEN 18 AND 24 THEN '18-24'
    WHEN age BETWEEN 25 AND 34 THEN '25-34'
    WHEN age BETWEEN 35 AND 44 THEN '35-44'
    WHEN age BETWEEN 45 AND 54 THEN '45-54'
    WHEN age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
END;

COMMIT;


/* =====================================================
   4. PRODUCT CLEANING
===================================================== */

START TRANSACTION;

-- Handle invalid categories
UPDATE stg_products
SET category = NULL
WHERE LOWER(category) = '???';

-- Handle missing colors
UPDATE stg_products
SET color = NULL
WHERE color IS NULL OR TRIM(color) = '';

-- Standardize numeric precision
UPDATE stg_products
SET cost_price = ROUND(cost_price, 2),
    list_price = ROUND(list_price, 2);

-- Convert data types
ALTER TABLE stg_products 
MODIFY cost_price DECIMAL(10,2);

ALTER TABLE stg_products 
MODIFY list_price DECIMAL(10,2);

COMMIT;


/* =====================================================
   5. SALES CLEANING
===================================================== */

START TRANSACTION;

-- Convert date format
ALTER TABLE stg_sales
MODIFY date DATE;

-- Handle missing discount values
UPDATE stg_sales
SET discount = NULL
WHERE discount = '';

-- Fix orphan product references
UPDATE stg_sales s
SET product_id = 'UNKNOWN'
WHERE NOT EXISTS (
    SELECT 1 
    FROM stg_products p 
    WHERE p.product_id = s.product_id
);

-- Handle missing customer IDs
UPDATE stg_sales
SET customer_id = NULL
WHERE customer_id = '';

COMMIT;


/* =====================================================
   6. FINAL DATA VALIDATION
===================================================== */

-- Check orphan records
SELECT COUNT(*) AS orphan_products
FROM stg_sales s
LEFT JOIN stg_products p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Check missing customer IDs
SELECT 
    COUNT(*) AS missing_customers
FROM stg_sales
WHERE customer_id IS NULL;
