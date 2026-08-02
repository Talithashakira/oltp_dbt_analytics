-- a singular test: any row this query returns is a failure.
-- price and freight_value should never be negative.
SELECT
    order_id,
    order_item_id,
    price,
    freight_value
FROM {{ ref('fact_orders') }}
WHERE price < 0 OR freight_value < 0
