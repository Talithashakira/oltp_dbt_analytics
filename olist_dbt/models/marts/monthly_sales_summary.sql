WITH fact_orders AS (
    SELECT * FROM {{ ref('fact_orders') }}
)

SELECT
    DATE_TRUNC('month', order_date)::date AS order_month,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(*) AS order_item_count,
    SUM(item_revenue) AS revenue,
    SUM(item_revenue) / COUNT(DISTINCT order_id) AS avg_order_value
FROM fact_orders
GROUP BY 1
ORDER BY 1
