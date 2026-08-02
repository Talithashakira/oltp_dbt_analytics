WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

category_translation AS (
    SELECT * FROM {{ ref('stg_product_category_translation') }}
)

SELECT
    products.product_id,
    products.product_category_name,
    COALESCE(
        category_translation.product_category_name_english,
        products.product_category_name
    ) AS product_category_name_english,
    products.product_name_length,
    products.product_description_length,
    products.product_photos_qty,
    products.product_weight_g,
    products.product_length_cm,
    products.product_height_cm,
    products.product_width_cm
FROM products
LEFT JOIN category_translation
    ON products.product_category_name = category_translation.product_category_name
