-- 2. Tạo schema marts
CREATE SCHEMA IF NOT EXISTS marts;

-- 3. Tạo Dimension Customer
-- Tạo bảng chứa thông tin khách hàng.
DROP TABLE IF EXISTS marts.dim_customer;

CREATE TABLE marts.dim_customer AS

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state

FROM staging.stg_customers;

-- 4. Tạo Dimension Product

DROP TABLE IF EXISTS marts.dim_product;

CREATE TABLE marts.dim_product AS

SELECT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm

FROM staging.stg_products;

-- 5. Tạo Dimension Date
-- Đây là bảng thời gian để phân tích doanh thu theo ngày, tháng, quý, năm.
DROP TABLE IF EXISTS marts.dim_date;

CREATE TABLE marts.dim_date AS

SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER
        AS date_key,

    date_value::DATE AS full_date,

    EXTRACT(DAY FROM date_value)::INTEGER
        AS day,

    EXTRACT(MONTH FROM date_value)::INTEGER
        AS month,

    EXTRACT(YEAR FROM date_value)::INTEGER
        AS year,

    EXTRACT(QUARTER FROM date_value)::INTEGER
        AS quarter,

    TO_CHAR(date_value, 'Month') AS month_name,

    TO_CHAR(date_value, 'Day') AS day_name,

    EXTRACT(ISODOW FROM date_value)::INTEGER
        AS day_of_week

FROM GENERATE_SERIES(
    (
        SELECT MIN(order_purchase_timestamp)::DATE
        FROM staging.stg_orders
    ),

    (
        SELECT MAX(order_purchase_timestamp)::DATE
        FROM staging.stg_orders
    ),

    INTERVAL '1 day'
) AS date_series(date_value);


-- 6. Tạo Fact Sales
-- Đây là bảng trung tâm của Data Warehouse.

-- Chúng ta kết hợp:
-- - Orders: thông tin đơn hàng.
-- - Order Items: chi tiết sản phẩm.
-- - Customers: thông tin khách hàng.
-- - Products: thông tin sản phẩm.
DROP TABLE IF EXISTS marts.fact_sales;

CREATE TABLE marts.fact_sales AS

SELECT
    oi.order_id,

    oi.order_item_id,

    o.customer_id,

    oi.product_id,

    oi.seller_id,

    o.order_status,

    o.order_purchase_timestamp::DATE
        AS order_date,

    TO_CHAR(
        o.order_purchase_timestamp,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    oi.price,

    oi.freight_value,

    (oi.price + oi.freight_value)
        AS total_item_value

FROM staging.stg_order_items oi

INNER JOIN staging.stg_orders o
    ON oi.order_id = o.order_id;