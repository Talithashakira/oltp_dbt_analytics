WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

-- customer_id is generated fresh for every order; customer_unique_id is the
-- stable identifier for the actual person. Rank each of a person's
-- customer_id rows by order recency so we can pick one "current" address.
customer_orders AS (
    SELECT
        customers.customer_unique_id,
        customers.customer_id,
        customers.customer_city,
        customers.customer_state,
        customers.customer_zip_code_prefix,
        ROW_NUMBER() OVER (
            PARTITION BY customers.customer_unique_id
            ORDER BY orders.order_purchase_timestamp DESC
        ) AS recency_rank
    FROM customers
    LEFT JOIN orders ON customers.customer_id = orders.customer_id
),

most_recent_location AS (
    SELECT
        customer_unique_id,
        customer_city AS current_city,
        customer_state AS current_state,
        customer_zip_code_prefix AS current_zip_code_prefix
    FROM customer_orders
    WHERE recency_rank = 1
),

customer_id_counts AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT customer_id) AS customer_id_count
    FROM customers
    GROUP BY customer_unique_id
)

SELECT
    most_recent_location.customer_unique_id,
    most_recent_location.current_city,
    most_recent_location.current_state,
    most_recent_location.current_zip_code_prefix,
    customer_id_counts.customer_id_count
FROM most_recent_location
LEFT JOIN customer_id_counts
    ON most_recent_location.customer_unique_id = customer_id_counts.customer_unique_id
