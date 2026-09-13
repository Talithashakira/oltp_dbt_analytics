WITH fact_orders AS (
    SELECT * FROM {{ ref('fact_orders') }}
),

dates AS (
    SELECT * FROM {{ ref('dim_date') }}
)

SELECT
    DATE_TRUNC('month', fact_orders.order_date)::date AS order_month,
    MAX(dates.year) AS year,
    MAX(dates.quarter) AS quarter,
    MAX(dates.month_name) AS month_name,
    COUNT(DISTINCT fact_orders.order_id) AS order_count,
    COUNT(*) AS order_item_count,
    SUM(fact_orders.item_revenue) AS revenue,
    SUM(fact_orders.item_revenue) / COUNT(DISTINCT fact_orders.order_id) AS avg_order_value
FROM fact_orders
LEFT JOIN dates ON fact_orders.order_date = dates.date_day
GROUP BY 1