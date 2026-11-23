-- =========================================================
-- Project: Olist E-Commerce Customer & Sales Analysis
-- File: 02_Exploratory_Data_Analysis.sql
-- Purpose: Analyzing logistics performance and customer purchasing behavior.
-- Author: Mohammadreza Aghebati
-- =========================================================

-- =========================================================
-- Section 1: Logistics & Delivery Performance
-- =========================================================

-- 1.1 Calculate the average delay (in days) for late deliveries
-- Objective: Understand how late the delayed orders are on average.
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