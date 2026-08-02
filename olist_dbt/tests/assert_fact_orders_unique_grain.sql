-- a singular test proving the documented grain of fact_orders: one row per
-- (order_id, order_item_id). Any group with count > 1 is a failure.
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS row_count
FROM {{ ref('fact_orders') }}
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
