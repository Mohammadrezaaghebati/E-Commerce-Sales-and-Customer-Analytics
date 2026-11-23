-- =========================================================
-- Project: Olist E-Commerce Customer & Sales Analysis
-- File: 01_Data_Cleaning.sql
-- Purpose: Data auditing, missing value detection, database
--          integrity validation, and chronological logic checks.
-- Author: Mohammadreza Aghebati
-- =========================================================

-- =========================================================
-- Section 1: Order Status & Delivery Date Validation
-- =========================================================

-- 1.1 Count orders with missing customer delivery dates
SELECT
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM
    dbo.olist_orders_dataset;
-- Result: 2,965 orders have no recorded customer delivery date.


-- 1.2 Analyze the status of orders with missing delivery dates
-- Objective: Identify whether missing dates are associated
-- with canceled, unavailable, or potentially inconsistent orders.
SELECT
    order_status,
    COUNT(*) AS status_count
FROM
    dbo.olist_orders_dataset
WHERE
    order_delivered_customer_date IS NULL
GROUP BY
    order_status
ORDER BY
    status_count DESC;
-- Analytical Finding: 8 orders are marked as 'delivered' despite having no 
-- recorded customer delivery date. This indicates a system recording bug.


-- =========================================================
-- Section 2: Customer Data Completeness Audit
-- =========================================================

-- 2.1 Check for missing values in customer location fields
-- Objective: Evaluate the completeness of customer address data.
SELECT
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS missing_zip_code,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS missing_state
FROM
    dbo.olist_customers_dataset;
-- Result: No missing values were found in the selected location fields.


-- =========================================================
-- Section 3: Data Integrity & Referential Consistency
-- =========================================================

-- 3.1 Validate customer ZIP codes against the geolocation table
-- Objective: Identify customer ZIP codes that have no matching
-- entry in the geolocation reference dataset (Orphan Records).
SELECT
    COUNT(*) AS missing_zip_codes
FROM
    dbo.olist_customers_dataset
WHERE
    customer_zip_code_prefix NOT IN (
        SELECT geolocation_zip_code_prefix
        FROM dbo.olist_geolocation_dataset
    );
-- Result: 278 customer records contain ZIP code prefixes that
-- are not available in the geolocation dataset.


-- 3.2 Validate product references in order items
-- Objective: Ensure that every product sold in an order
-- exists in the main products dataset.
SELECT
    COUNT(*) AS missing_products
FROM
    dbo.olist_order_items_dataset
WHERE
    product_id NOT IN (
        SELECT product_id
        FROM dbo.olist_products_dataset
    );
-- Result: 0 orphan product references were found. Data is highly consistent.


-- =========================================================
-- Section 4: Date & Time Logic Validation (Chronological Checks)
-- =========================================================

-- 4.1 Check for missing timestamps in key order date columns
SELECT 
    COUNT(order_purchase_timestamp) AS total_purchase_timestamps,
    COUNT(order_delivered_customer_date) AS total_delivered_dates,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_timestamp,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivered_customer_date
FROM 
    dbo.olist_orders_dataset;
-- Result: 99,441 purchase timestamps and 96,476 delivery dates. Difference is exactly 2,965 (matched with Section 1.1).


-- 4.2 Check for time-traveling logic errors
-- Objective: Ensure no order was delivered BEFORE it was actually purchased.
SELECT
    COUNT(*) AS chronological_errors
FROM 
    dbo.olist_orders_dataset
WHERE 
    order_purchase_timestamp > order_delivered_customer_date;
-- Result: 0 errors. Data follows a logical chronological order.


-- =========================================================
-- Section 5: Logistics Performance Metrics (Late Deliveries)
-- =========================================================

-- 5.1 Count late deliveries
-- Objective: Identify orders where the actual delivery date 
-- was later than the estimated delivery date.
SELECT
    COUNT(*) AS late_deliveries
FROM 
    dbo.olist_orders_dataset
WHERE 
    order_estimated_delivery_date < order_delivered_customer_date;
-- Result: 7,827 orders were delivered later than estimated (approx 8% of total delivered orders).