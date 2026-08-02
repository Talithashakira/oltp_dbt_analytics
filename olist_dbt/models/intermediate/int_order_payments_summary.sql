WITH payments AS (
    SELECT * FROM {{ ref('stg_order_payments') }}
),

ranked_payments AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC
        ) AS payment_rank
    FROM payments
)

SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    COUNT(*) AS payment_count,
    MAX(payment_installments) AS max_installments,
    MAX(CASE WHEN payment_rank = 1 THEN payment_type END) AS primary_payment_type
FROM ranked_payments
GROUP BY order_id
