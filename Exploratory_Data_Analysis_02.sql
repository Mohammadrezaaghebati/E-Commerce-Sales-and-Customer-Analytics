-- =========================================================
-- Project: Olist E-Commerce Customer & Sales Analysis
-- File: 02_Exploratory_Data_Analysis.sql
-- Purpose: Analyzing logistics performance, customer purchasing behavior, and revenue generation.
-- Author: Mohammadreza Aghebati
-- =========================================================

-- =========================================================
-- Section 1: Logistics & Delivery Performance
-- =========================================================

-- 1.1 Calculate the average delay (in days) for late deliveries
-- Objective: Understand how late the delayed orders arrive on average.
SELECT 
    AVG(DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date)) AS avg_delay_days
FROM 
    dbo.olist_orders_dataset
WHERE 
    order_estimated_delivery_date < order_delivered_customer_date;
-- Result: Delayed orders arrive an average of 8 days late.

-- =========================================================
-- Section 2: Consumer Behavior (Purchase Timing)
-- =========================================================

-- 2.1 Analyze order volume by day of the week
-- Objective: Identify peak shopping days to optimize marketing campaigns.
SELECT
    DATENAME(WEEKDAY, order_purchase_timestamp) AS day_of_week, 
    COUNT(*) AS total_orders
FROM 
    dbo.olist_orders_dataset
GROUP BY 
    DATENAME(WEEKDAY, order_purchase_timestamp)
ORDER BY 
    total_orders DESC;
-- Result: Monday is the peak shopping day.

-- 2.2 Analyze order volume by hour of the day
-- Objective: Identify peak shopping hours for targeted ads and SMS timing.
SELECT
    DATENAME(HOUR, order_purchase_timestamp) AS hour_of_day, 
    COUNT(*) AS total_orders
FROM 
    dbo.olist_orders_dataset
GROUP BY 
    DATENAME(HOUR, order_purchase_timestamp)
ORDER BY 
    total_orders DESC;
-- Result: 16:00 (4 PM) and evening hours (20:00 - 22:00) show the highest sales volume.

-- =========================================================
-- Section 3: Product Revenue Analysis (Cash Cows)
-- =========================================================

-- 3.1 Find the top revenue-generating individual products
-- Objective: Identify specific high-value items driving sales.
SELECT 
    product_id,
    SUM(price) AS total_revenue
FROM 
    dbo.olist_order_items_dataset
GROUP BY 
    product_id
ORDER BY 
    total_revenue DESC;
-- Result: Top product generated approximately 269.97 in revenue.

-- 3.2 Translate the category of a specific high-revenue product
-- Objective: Determine the original Portuguese category for a specific top-selling product ID.
SELECT
    product_category_name
FROM 
    dbo.olist_products_dataset
WHERE 
    product_id = 'bb50f2e236e5eea0100680137654686c';
-- Result: The product belongs to the 'beleza_saude' category.

-- 3.3 Find the top product categories by total revenue (English names)
-- Objective: Identify the highest-grossing categories for marketing budget allocation by joining with the translation table.
SELECT 
    translation.column2 AS product_category_english,
    SUM(items.price) AS total_revenue
FROM 
    dbo.olist_products_dataset AS products
INNER JOIN 
    dbo.olist_order_items_dataset AS items
    ON products.product_id = items.product_id
INNER JOIN 
    dbo.product_category_name_translation AS translation
    ON products.product_category_name = translation.column1
GROUP BY 
    translation.column2
ORDER BY 
    total_revenue DESC;
-- Result: 'health_beauty' is the most profitable category.

-- =========================================================
-- Section 4: Customer Analysis (VIPs & Lifetime Value)
-- =========================================================

-- 4.1 Find the top 10 VIP customers by total lifetime value (LTV)
-- Objective: Identify the highest-spending unique customers for loyalty programs.
SELECT TOP 10
    customers.customer_unique_id,
    SUM(items.price) AS total_revenue
FROM 
    dbo.olist_order_items_dataset AS items
INNER JOIN 
    dbo.olist_orders_dataset AS orders
    ON items.order_id = orders.order_id
INNER JOIN 
    dbo.olist_customers_dataset AS customers
    ON orders.customer_id = customers.customer_id
GROUP BY 
    customers.customer_unique_id
ORDER BY 
    total_revenue DESC;
-- Result: Customer '0a0a9211...' is the top VIP with 13,440 in total revenue.

-- =========================================================
-- Section 5: Geographical Sales Analysis
-- =========================================================

-- 5.1 Find the top 10 highest-grossing customer cities
-- Objective: Identify key geographical markets for localized marketing and warehouse placement.
SELECT TOP 10
    customers.customer_city,
    SUM(items.price) AS total_revenue
FROM 
    dbo.olist_orders_dataset AS orders
INNER JOIN
    dbo.olist_order_items_dataset AS items
    ON orders.order_id = items.order_id
INNER JOIN
    dbo.olist_customers_dataset AS customers
    ON orders.customer_id = customers.customer_id
GROUP BY 
    customers.customer_city
ORDER BY 
    total_revenue DESC;
-- Result: Sao Paulo is the leading market with ~1.91M in revenue, followed by Rio de Janeiro.