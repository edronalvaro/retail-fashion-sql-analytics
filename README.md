# Fashion Retail SQL Analysis

## Project Overview
This project analyzes a fashion retail dataset to uncover insights into customer behavior, product performance, store performance, and revenue trends.  

The goal is to simulate a real-world retail analytics environment by performing end-to-end SQL analysis, including data cleaning, transformation, and business insights.

---

## Business Objectives
- Identify top-performing and underperforming products and categories  
- Analyze customer purchasing behavior by age demographics  
- Evaluate store and regional performance  
- Measure the impact of discounts on revenue and profit  
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
    CASE 
        WHEN c.age BETWEEN 16 AND 24 THEN '16-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN c.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount, 0))) AS revenue
FROM customers_clean c
JOIN sales_clean s ON c.customer_id = s.customer_id
JOIN products_clean p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY revenue DESC;
