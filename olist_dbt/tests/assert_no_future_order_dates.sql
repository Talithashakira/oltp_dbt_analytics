-- a singular test: any row this query returns is a failure.
-- an order can't be purchased after the moment this test runs.
SELECT
    order_id,
    order_purchase_timestamp
FROM {{ ref('stg_orders') }}
WHERE order_purchase_timestamp > CURRENT_TIMESTAMP
