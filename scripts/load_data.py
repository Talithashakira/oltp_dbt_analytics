import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('postgresql+psycopg2://user:12345678@localhost:5432/dbtproject')

file_to_table_map = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_name_translation",
}

for filename, table_name in file_to_table_map.items():
    print(f"Loading {filename} -> raw.{table_name} ...")

    df = pd.read_csv(f"data_raw/{filename}")

    df.to_sql(
        table_name,
        engine,
        schema="raw",
        if_exists="replace",
        index=False,
    )

    print(f"done: {len(df)} rows")
    print(f"{table_name} table loaded successfully")

print("All tables loaded successfully")