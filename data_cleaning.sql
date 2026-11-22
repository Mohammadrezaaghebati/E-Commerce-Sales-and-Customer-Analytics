
-- =========================================================
-- Project: Olist E-Commerce Customer & Sales Analysis
-- File: 01_Data_Cleaning.sql
-- Purpose:
-- Data auditing, missing value detection, and database
-- integrity validation.
-- =========================================================


-- =========================================================
-- Section 1: Order Status & Delivery Date Validation
-- =========================================================

-- 1.1 Count orders with missing customer delivery dates

SELECT
    SUM(
        CASE
            WHEN order_delivered_customer_date IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_delivery_date
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

-- Analytical Finding:
-- 8 orders are marked as 'delivered' despite having no
-- recorded customer delivery date.
-- This may indicate a data recording inconsistency
-- that requires further investigation.


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

-- Result:
-- No missing values were found in the selected customer
-- location fields (city, ZIP code, and state).


-- =========================================================
-- Section 3: Data Integrity & Referential Consistency
-- =========================================================

/*
Data Integrity Note:

To identify orphan records, we need to validate relationships
between tables rather than simply checking for NULL values.

The following queries use NOT IN to identify records whose
reference values do not exist in the corresponding lookup tables.
*/


-- 3.1 Validate customer ZIP codes against the geolocation table
-- Objective: Identify customer ZIP codes that have no matching
-- entry in the geolocation reference dataset.

SELECT
    COUNT(*) AS missing_zip_codes
FROM
    dbo.olist_customers_dataset
WHERE
    customer_zip_code_prefix NOT IN (
        SELECT
            geolocation_zip_code_prefix
        FROM
            dbo.olist_geolocation_dataset
    );

-- Result:
-- 278 customer records contain ZIP code prefixes that
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
        SELECT
            product_id
        FROM
            dbo.olist_products_dataset
    );

-- Result:
-- 0 orphan product references were found.
-- All products referenced in order items exist in the
-- main products dataset.
