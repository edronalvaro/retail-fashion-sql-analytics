-- =====================================================
-- BUSINESS OBJECTIVE
-- =====================================================

/*
The goal of this analysis is to understand:
1. Which products, categories, and colors drive revenue and profit
2. How customer demographics influence purchasing behavior
3. Which stores and regions are performing best
4. Reveal revenue distribution between discount levels
5. Identify business risks and opportunities for optimization
*/

-- =====================================================
-- 1. EXECUTIVE KPIs
-- =====================================================

SELECT 
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS total_revenue,

    SUM(s.quantity * (p.list_price * (1 - COALESCE(s.discount,0)) - p.cost_price)) AS total_profit,

    ROUND(
        SUM(s.quantity * (p.list_price * (1 - COALESCE(s.discount,0)) - p.cost_price))
        / NULLIF(SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))),0)
    ,2) AS profit_margin
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0;

-- =====================================================
-- 2. CUSTOMER ANALYSIS
-- =====================================================

-- Revenue by Age Group
SELECT 
    CASE 
        WHEN c.age BETWEEN 16 AND 24 THEN '16-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN c.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue
FROM sales_clean s
JOIN customers_clean c ON s.customer_id = c.customer_id
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY 1
ORDER BY revenue DESC;

-- Top Customers (Revenue Concentration)
SELECT 
    c.customer_id,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS total_revenue,
    ROW_NUMBER() OVER (
        ORDER BY SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) DESC
    ) AS ranking
FROM sales_clean s
JOIN customers_clean c ON s.customer_id = c.customer_id
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY c.customer_id
LIMIT 10;

-- =====================================================
-- 3. PRODUCT ANALYSIS
-- =====================================================

-- Revenue by Category
SELECT 
    COALESCE(p.category, 'Unknown') AS category,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY 1
ORDER BY revenue DESC;

-- Profit by Category
SELECT 
    COALESCE(p.category, 'Unknown') AS category,
    SUM(s.quantity * (p.list_price * (1 - COALESCE(s.discount,0)) - p.cost_price)) AS profit
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY 1
ORDER BY profit DESC;

-- Category Ranking (Revenue)
SELECT 
    p.category,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue,
    RANK() OVER (
        ORDER BY SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) DESC
    ) AS ranking
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY p.category;

-- Color Preference
SELECT 
    COALESCE(p.color, 'Unknown') AS color,
    SUM(s.quantity) AS units_sold
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY units_sold DESC;

-- =====================================================
-- 4. STORE & REGION PERFORMANCE
-- =====================================================

-- Revenue by Store
SELECT 
    st.store_name,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue
FROM sales_clean s
JOIN stores_clean st ON s.store_id = st.store_id
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY st.store_name
ORDER BY revenue DESC;

-- Region Performance
SELECT 
    st.region,
    SUM(s.quantity) AS units_sold,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue,
    SUM(s.quantity * (p.list_price * (1 - COALESCE(s.discount,0)) - p.cost_price)) AS profit
FROM sales_clean s
JOIN stores_clean st ON s.store_id = st.store_id
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY st.region
ORDER BY profit DESC;

-- =====================================================
-- 5. TIME SERIES ANALYSIS
-- =====================================================

-- Monthly Revenue + MoM Growth
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(s.date, '%Y-%m') AS month,
        SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue
    FROM sales_clean s
    JOIN products_clean p ON s.product_id = p.product_id
    WHERE p.price_issue_flag = 0
    GROUP BY 1
),
lagged AS (
    SELECT 
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_month
    FROM monthly_revenue
)

SELECT 
    month,
    revenue,
    ROUND((revenue - prev_month) / NULLIF(prev_month,0) * 100,2) AS mom_growth_pct
FROM lagged;

-- =====================================================
-- 6. DISCOUNT DISTRIBUTION BY DISCOUNT LEVEL
-- =====================================================

SELECT 
    COALESCE(s.discount,0) AS discount_rate,
    SUM(s.quantity * p.list_price) AS gross_revenue,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS net_revenue,
    SUM(s.quantity * p.list_price * COALESCE(s.discount,0)) AS discount_value
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
WHERE p.price_issue_flag = 0
GROUP BY 1
ORDER BY discount_rate;

-- =====================================================
-- 7. BUSINESS DECISION ANALYSIS
-- =====================================================

-- High Revenue vs Profit Balance
SELECT 
    p.category,
    SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue,
    SUM(s.quantity * (p.list_price * (1 - COALESCE(s.discount,0)) - p.cost_price)) AS profit
FROM sales_clean s
JOIN products_clean p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Customer Concentration Risk
SELECT 
    customer_id,
    revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC) /
    SUM(revenue) OVER () AS cumulative_share
FROM (
    SELECT 
        c.customer_id,
        SUM(s.quantity * p.list_price * (1 - COALESCE(s.discount,0))) AS revenue
    FROM sales_clean s
    JOIN customers_clean c ON s.customer_id = c.customer_id
    JOIN products_clean p ON s.product_id = p.product_id
    GROUP BY c.customer_id
) t
ORDER BY revenue DESC
LIMIT 10;
