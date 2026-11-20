
CREATE OR REPLACE VIEW staging.stg_orders AS

SELECT
    TRIM(order_id) AS order_id,

    TRIM(customer_id) AS customer_id,

    LOWER(TRIM(order_status)) AS order_status,

    NULLIF(
        TRIM(order_purchase_timestamp::TEXT), ''
    )::TIMESTAMP AS order_purchase_timestamp,

    NULLIF(
        TRIM(order_approved_at::TEXT), ''
    )::TIMESTAMP AS order_approved_at,

    NULLIF(
        TRIM(order_delivered_carrier_date::TEXT), ''
    )::TIMESTAMP AS order_delivered_carrier_date,

    NULLIF(
        TRIM(order_delivered_customer_date::TEXT), ''
    )::TIMESTAMP AS order_delivered_customer_date,

    NULLIF(
        TRIM(order_estimated_delivery_date::TEXT), ''
    )::TIMESTAMP AS order_estimated_delivery_date

FROM raw.orders

WHERE order_id IS NOT NULL;


-- Chuẩn hóa bảng order_items

CREATE OR REPLACE VIEW staging.stg_order_items AS

SELECT
    TRIM(order_id) AS order_id,

    order_item_id::INTEGER AS order_item_id,

    TRIM(product_id) AS product_id,

    TRIM(seller_id) AS seller_id,

    NULLIF(
        TRIM(shipping_limit_date::TEXT), ''
    )::TIMESTAMP AS shipping_limit_date,

    price::NUMERIC(12,2) AS price,

    freight_value::NUMERIC(12,2) AS freight_value

FROM raw.order_items

WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL;

--   Chuẩn hóa bảng customers

CREATE OR REPLACE VIEW staging.stg_customers AS

SELECT
    TRIM(customer_id) AS customer_id,

    TRIM(customer_unique_id) AS customer_unique_id,

    customer_zip_code_prefix::INTEGER
        AS customer_zip_code_prefix,

    LOWER(TRIM(customer_city)) AS customer_city,

    UPPER(TRIM(customer_state)) AS customer_state

FROM raw.customers

WHERE customer_id IS NOT NULL;

-- Chuẩn hóa bảng products
CREATE OR REPLACE VIEW staging.stg_products AS

SELECT
    TRIM(product_id) AS product_id,

    COALESCE(
        NULLIF(TRIM(product_category_name), ''),
        'unknown'
    ) AS product_category_name,

    product_name_lenght::INTEGER
        AS product_name_length,

    product_description_lenght::INTEGER
        AS product_description_length,

    product_photos_qty::INTEGER
        AS product_photos_qty,

    product_weight_g::NUMERIC
        AS product_weight_g,

    product_length_cm::NUMERIC
        AS product_length_cm,

    product_height_cm::NUMERIC
        AS product_height_cm,

    product_width_cm::NUMERIC
        AS product_width_cm

FROM raw.products

WHERE product_id IS NOT NULL;

-- Chuẩn hóa bảng payments

CREATE OR REPLACE VIEW staging.stg_payments AS

SELECT
    TRIM(order_id) AS order_id,

    payment_sequential::INTEGER AS payment_sequential,

    LOWER(TRIM(payment_type)) AS payment_type,

    payment_installments::INTEGER
        AS payment_installments,

    payment_value::NUMERIC(12,2) AS payment_value

FROM raw.payments

WHERE order_id IS NOT NULL;