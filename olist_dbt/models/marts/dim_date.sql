-- hand-rolled date spine (no dbt_utils installed yet — see Day 5 note
-- about swapping this for dbt_utils.date_spine later)
WITH bounds AS (
    SELECT
        MIN(order_purchase_timestamp)::date AS min_date,
        MAX(order_estimated_delivery_date)::date AS max_date
    FROM {{ ref('stg_orders') }}
),

date_spine AS (
    SELECT generate_series(
        (SELECT min_date FROM bounds),
        (SELECT max_date FROM bounds),
        interval '1 day'
    )::date AS date_day
)

SELECT
    date_day,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    EXTRACT(MONTH FROM date_day) AS month,
    TRIM(TO_CHAR(date_day, 'Month')) AS month_name,
    EXTRACT(DAY FROM date_day) AS day_of_month,
    EXTRACT(ISODOW FROM date_day) AS day_of_week,
    TRIM(TO_CHAR(date_day, 'Day')) AS day_name,
    EXTRACT(ISODOW FROM date_day) IN (6, 7) AS is_weekend
FROM date_spine
