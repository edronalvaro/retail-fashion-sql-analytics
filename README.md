# Fashion Retail SQL Analysis

## Project Overview
This project analyzes a synthetic fashion retail dataset to uncover insights into customer behavior, product performance, store performance, and revenue trends.  

The goal is to simulate a real-world retail analytics environment by performing end-to-end SQL analysis, including data cleaning, transformation, and business insights.

---

## Business Objectives
- Identify top-performing and underperforming products and categories  
- Analyze customer purchasing behavior by age demographics  
- Evaluate store and regional performance  
- Analyze revenue distribution across discount levels
- Identify monthly sales trends and seasonality patterns  

---

## Data Cleaning & Preparation

The raw dataset was cleaned and transformed to ensure accuracy and consistency:

- Created staging tables for safe transformations  
- Identified and handled duplicate transaction records  
- Standardized inconsistent categorical values (e.g. gender = '???')  
- Converted blank values to NULL  
- Converted data types (prices → DECIMAL, dates → DATE)  
- Created customer age group segmentation  
- Fixed missing product and store references  

---

## Key SQL Analysis

### 1. Revenue by Age Group
```sql
SELECT 
    customer_id,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS total_revenue,
    ROW_NUMBER() OVER (
        ORDER BY SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) DESC
    ) AS ranking
FROM sales_clean s
JOIN customers_clean c ON s.customer_id = c.customer_id
JOIN products_clean p ON s.product_id = p.product_id
GROUP BY c.customer_id
LIMIT 10;
