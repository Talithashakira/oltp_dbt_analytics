WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

payments_summary AS (
    SELECT * FROM {{ ref('int_order_payments_summary') }}
),

reviews_summary AS (
    SELECT * FROM {{ ref('int_order_reviews_summary') }}
)

SELECT
    -- keys
    order_items.order_id,
    order_items.order_item_id,
    order_items.product_id,
    order_items.seller_id,
    orders.customer_id,
    customers.customer_unique_id,
    orders.order_purchase_timestamp::date AS order_date,

    -- item-level measures: one row per item, so these are additive/safe to SUM
    order_items.price,
    order_items.freight_value,
    order_items.price + order_items.freight_value AS item_revenue,

    -- order-level attributes repeated on every item row of a multi-item
    -- order. Fine to filter/group by, but SUMing order_total_payment_value
    -- across items of the same order will double count — aggregate it at
    -- the order grain first (see int_order_payments_summary) if you need a
    -- payment total.
    orders.order_status,
    orders.order_purchase_timestamp,
    orders.order_delivered_customer_date,
    orders.order_estimated_delivery_date,
    payments_summary.total_payment_value AS order_total_payment_value,
    payments_summary.primary_payment_type,
    reviews_summary.review_score

FROM order_items
LEFT JOIN orders ON order_items.order_id = orders.order_id
LEFT JOIN customers ON orders.customer_id = customers.customer_id
LEFT JOIN payments_summary ON order_items.order_id = payments_summary.order_id
LEFT JOIN reviews_summary ON order_items.order_id = reviews_summary.order_id
