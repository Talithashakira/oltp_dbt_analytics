WITH fact_orders AS (
    SELECT * FROM {{ ref('fact_orders') }}
)

SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(item_revenue) AS total_spend,
    SUM(item_revenue) / COUNT(DISTINCT order_id) AS avg_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS most_recent_order_date
FROM fact_orders
GROUP BY customer_unique_id
