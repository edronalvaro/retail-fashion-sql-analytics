-- =====================================================
-- FASHION RETAIL DATABASE SCHEMA
-- This file documents the structure of the database
-- imported from raw dataset files.
-- =====================================================

-- TABLE: customers
-- Purpose: Stores customer demographic information

/*
Columns:
- customer_id (text)
- age (INT)
- gender (text)
- email (text)
*/

-- TABLE: products
-- Purpose: Stores product-level information

/*
Columns:
- product_id (text)
- category (text)
- color (text)
- size (text)
- cost_price (double)
- list_price (double)
*/

-- TABLE: stores
-- Purpose: Stores retail store information

/*
Columns:
- store_id (text)
- store_name (text)
- region (text)
- store_size_m2 (INT)
*/

-- TABLE: sales
-- Purpose: Transaction-level sales data

/*
Columns:
- transaction_id (text)
- date (text)
- product_id (text)
- store_id (text)
- customer_id (text)
- quantity (INT)
- discount (text)
- returned (INT)
*/
