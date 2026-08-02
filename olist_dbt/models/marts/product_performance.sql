WITH fact_orders AS (
    SELECT * FROM {{ ref('fact_orders') }}
),

products AS (
    SELECT * FROM {{ ref('dim_products') }}
)

SELECT
    products.product_id,
    products.product_category_name_english,
    COUNT(*) AS units_sold,
    SUM(fact_orders.item_revenue) AS total_revenue,
    -- review_score is an order-level attribute repeated on every item row,
    -- so a product bought several times in the same order counts that
    -- order's review once per unit — treat this as unit-weighted, not
    -- order-weighted, satisfaction
    AVG(fact_orders.review_score) AS avg_review_score
FROM fact_orders
LEFT JOIN products ON fact_orders.product_id = products.product_id
GROUP BY 1, 2
