# Fashion Retail SQL Analysis

## Project Overview

This project analyzes a synthetic fashion retail dataset to uncover insights into customer purchasing behavior, product performance, store performance, and revenue trends.

The project follows an end-to-end analytics workflow using MySQL, including data validation, data cleaning, transformation, and business-focused SQL analysis.

> **Note:** This project uses a synthetic dataset designed for analytical practice. The purpose of this project is to demonstrate SQL data cleaning, relational database analysis, and business problem-solving rather than represent real-world financial performance.

---

# Business Objectives

The goal of this analysis is to understand:

- Which product categories drive revenue and profitability
- How customer demographics influence purchasing behavior
- Which stores and regions perform best
- How discount levels impact revenue
- Monthly revenue trends and growth patterns
- Whether revenue is concentrated among a small group of customers

---

# Tools Used

- MySQL

---

# Dataset

The dataset contains four relational tables:

### Customers
Contains customer demographic information:
- Customer ID
- Age
- Gender
- City
- Email

### Products
Contains product-level information:
- Product ID
- Category
- Color
- Size
- Season
- Supplier
- Cost Price
- List Price

### Sales
Contains transaction-level sales data:
- Transaction ID
- Date
- Product ID
- Store ID
- Customer ID
- Quantity
- Discount
- Returned Status

### Stores
Contains store information:
- Store ID
- Store Name
- Region
- Store Size

---

# Data Cleaning Process

A staging layer was created before analysis to preserve the original raw tables.

Cleaning and validation steps included:

- Created staging tables from raw data
- Standardized text fields using `LOWER()` and `TRIM()`
- Converted blank values into `NULL`
- Handled missing customer email values
- Standardized inconsistent category values
- Handled missing product color values
- Created customer age groups
- Rounded pricing fields for consistency
- Flagged products where `List Price < Cost Price`
- Validated duplicate transactions
- Checked for orphan product references
- Standardized date and numeric data types

---

# SQL Skills Demonstrated

This project demonstrates:

- Multi-table `INNER JOIN` operations
- Data cleaning and validation workflows
- Common Table Expressions (CTEs)
- Window Functions:
  - `ROW_NUMBER()`
  - `RANK()`
  - `LAG()`
  - `SUM() OVER()`
- Aggregate functions
- Conditional logic using `CASE`
- Date functions
- NULL handling using `COALESCE()`
- Business KPI calculations
- Revenue and profitability analysis

---

# Key SQL Analysis

## Executive KPIs

Calculated:

- Total Revenue
- Total Profit
- Profit Margin

Results:

- **Total Revenue:** $11.73M
- **Total Profit:** $7.64M
- **Profit Margin:** 65%

> Results are based on a synthetic dataset and are intended to demonstrate analytical techniques rather than represent realistic retail benchmarks.

---

## Customer Revenue Ranking

Identified the highest-value customers by calculating total revenue contribution.

SQL techniques used:

- Multiple table joins
- Aggregation
- Window functions (`ROW_NUMBER`)

Example:

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
