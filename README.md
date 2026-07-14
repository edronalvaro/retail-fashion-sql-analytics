# Fashion Retail SQL Analysis

## Project Overview

This project analyzes a synthetic fashion retail dataset to uncover insights into customer purchasing behavior, product performance, store performance, and revenue trends.

The project follows a complete analytics workflow, including data cleaning, data validation, SQL analysis, and business recommendations using MySQL.

> **Note:** This project uses a synthetic dataset for analytical practice. The objective is to demonstrate SQL-based data cleaning, transformation, and business analysis techniques rather than model real-world financial performance.

---

## Business Objectives

- Analyze revenue and profit across product categories
- Identify customer purchasing trends by age group
- Evaluate store and regional performance
- Measure revenue distribution across discount levels
- Analyze monthly revenue trends and month-over-month growth
- Assess customer revenue concentration

---

## Tools Used

- MySQL

---

## Dataset

The dataset contains four relational tables:

- **Customers** – customer demographics
- **Products** – product attributes and pricing
- **Sales** – transaction-level sales records
- **Stores** – store information and regions

---

## Data Cleaning

A complete staging layer was created before analysis.

Cleaning steps included:

- Created staging tables to preserve raw data
- Standardized text values using `LOWER()` and `TRIM()`
- Handled missing values and blank fields
- Converted empty strings to `NULL`
- Created customer age groups
- Rounded pricing fields for consistency
- Flagged products where `List Price < Cost Price`
- Validated duplicate transactions
- Checked for orphan customer and product records
- Standardized date and numeric data types

---

## SQL Skills Demonstrated

- INNER JOINs across multiple tables
- Common Table Expressions (CTEs)
- Window Functions (`ROW_NUMBER`, `RANK`, `LAG`, `SUM OVER`)
- CASE statements
- Aggregate Functions
- Date Functions
- NULL handling with `COALESCE()`
- Data validation and cleaning
- Business KPI calculations

---

## Key SQL Analysis

### Executive KPIs

Calculated:

- Total Revenue
- Total Profit
- Profit Margin

Result:

- **Total Revenue:** \$11.73M
- **Total Profit:** \$7.64M
- **Profit Margin:** 65%

---

### Customer Revenue Ranking

Used a window function to rank customers based on total revenue generated.

```sql
SELECT
    c.customer_id,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS total_revenue,
    ROW_NUMBER() OVER (
        ORDER BY SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) DESC
    ) AS ranking
FROM sales_clean s
JOIN customers_clean c
    ON s.customer_id = c.customer_id
JOIN products_clean p
    ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY c.customer_id
LIMIT 10;
