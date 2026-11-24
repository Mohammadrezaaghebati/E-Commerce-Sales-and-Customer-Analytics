-- =========================================================
-- Project: Olist E-Commerce Customer & Sales Analysis
-- File: 03_Data_Preparation_for_BI.sql
-- Purpose: Creating views to feed clean, structured data into Power BI.
-- Author: Mohammadreza Aghebati
-- =========================================================

-- =========================================================
-- Section 1: Base Views
-- =========================================================

-- 1.1 Create a clean view for delivered orders only
-- Objective: Filter out canceled orders and missing delivery dates to ensure accurate logistics metrics.
CREATE VIEW vw_delivered_orders_clean AS 
SELECT *
FROM dbo.olist_orders_dataset
WHERE 
    order_delivered_customer_date IS NOT NULL 
    AND order_status = 'delivered';

-- =========================================================
-- Section 2: Master Views for BI
-- =========================================================

-- 2.1 Create a Sales Master View
-- Objective: Combine order, item, and customer data into a single, optimized virtual table for BI dashboards.
CREATE VIEW vw_sales_master AS
SELECT 
    orders.order_id,
    orders.customer_id,
    orders.order_status,
    orders.order_purchase_timestamp,
    orders.order_delivered_customer_date,
    items.product_id,
    items.price,
    items.freight_value,
    customers.customer_unique_id,
    customers.customer_city,
    customers.customer_state
FROM vw_delivered_orders_clean AS orders
INNER JOIN dbo.olist_order_items_dataset AS items
    ON items.order_id = orders.order_id
INNER JOIN dbo.olist_customers_dataset AS customers
    ON customers.customer_id = orders.customer_id;