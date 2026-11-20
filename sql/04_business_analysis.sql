-- 1. Tổng quan doanh thu và đơn hàng
-- Doanh nghiệp đang có bao nhiêu đơn hàng và tổng doanh thu là bao nhiêu?
SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(*) AS total_order_items,

    SUM(price) AS total_revenue,

    SUM(freight_value) AS total_freight,

    SUM(total_item_value) AS total_sales_including_freight

FROM marts.fact_sales
WHERE order_status = 'delivered';


-- 2. Doanh thu theo tháng
-- Tháng nào có doanh thu cao nhất? Doanh thu có tăng trưởng không?
SELECT
    d.year,
    d.month,

    SUM(f.price) AS monthly_revenue,

    COUNT(DISTINCT f.order_id) AS total_orders

FROM marts.fact_sales f

JOIN marts.dim_date d
    ON f.date_key = d.date_key

WHERE f.order_status = 'delivered'

GROUP BY
    d.year,
    d.month

ORDER BY
    d.year,
    d.month;
	
-- 3. Top 10 sản phẩm có doanh thu cao nhất
-- Sản phẩm nào đang đóng góp nhiều doanh thu nhất?
SELECT
    p.product_id,

    p.product_category_name,

    SUM(f.price) AS total_revenue,

    SUM(1) AS total_items_sold

FROM marts.fact_sales f

JOIN marts.dim_product p
    ON f.product_id = p.product_id

WHERE f.order_status = 'delivered'

GROUP BY
    p.product_id,
    p.product_category_name

ORDER BY total_revenue DESC

LIMIT 10;

-- 4. Top 10 khách hàng mua hàng nhiều nhất
-- Khách hàng nào có số lượng đơn hàng cao nhất?
SELECT
    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.price) AS total_spending

FROM marts.fact_sales f

JOIN marts.dim_customer c
    ON f.customer_id = c.customer_id

WHERE f.order_status = 'delivered'

GROUP BY
    c.customer_unique_id,
    c.customer_city,
    c.customer_state

ORDER BY total_spending DESC

LIMIT 10;

-- 5. Phân tích trạng thái đơn hàng
-- Bao nhiêu phần trăm đơn hàng đã giao thành công, bị hủy hoặc đang xử lý?
WITH order_status_summary AS (

    SELECT
        order_id,
        order_status
    FROM marts.fact_sales
    GROUP BY order_id, order_status

)

SELECT
    order_status,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM order_status_summary

GROUP BY order_status

ORDER BY total_orders DESC;

-- 6. Phân tích thời gian giao hàng
-- Trung bình doanh nghiệp mất bao nhiêu ngày để giao một đơn hàng?
SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS avg_delivery_days

FROM staging.stg_orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;
 
-- 7. Phân tích phương thức thanh toán
-- Khách hàng thường sử dụng phương thức thanh toán nào?
SELECT
    payment_type,

    COUNT(*) AS total_transactions,

    SUM(payment_value) AS total_payment_value,

    ROUND(
        AVG(payment_value),
        2
    ) AS avg_payment_value

FROM staging.stg_payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;