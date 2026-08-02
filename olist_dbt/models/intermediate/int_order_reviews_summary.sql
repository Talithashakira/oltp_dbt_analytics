WITH reviews AS (
    SELECT * FROM {{ ref('stg_order_reviews') }}
),

-- an order can have more than one review row in this dataset;
-- keep only the most recent one so this model is one row per order
ranked_reviews AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_creation_date DESC
        ) AS review_rank
    FROM reviews
)

SELECT
    order_id,
    review_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
FROM ranked_reviews
WHERE review_rank = 1
