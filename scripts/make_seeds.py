"""
Ambil sampel kecil yang konsisten secara relasional dari schema raw,
simpan sebagai CSV di olist_dbt/seeds/ untuk dipakai CI.

Jalankan sekali secara lokal, lalu commit hasilnya ke git.
"""

import pandas as pd
from sqlalchemy import create_engine, text
from pathlib import Path

engine = create_engine('postgresql+psycopg2://user:12345678@localhost:5432/dbtproject')
SEED_DIR = Path(__file__).resolve().parent.parent / "olist_dbt" / "seeds"
SEED_DIR.mkdir(parents=True, exist_ok=True)

N_ORDERS = 500

with engine.connect() as conn:
    # 1. Ambil order yang PUNYA item, supaya sampelnya bermakna
    orders = pd.read_sql(text(f"""
        SELECT o.* FROM raw.orders o
        WHERE EXISTS (SELECT 1 FROM raw.order_items i WHERE i.order_id = o.order_id)
        ORDER BY o.order_id
        LIMIT {N_ORDERS}
    """), conn)

    order_ids = tuple(orders["order_id"])

    # 2. Semua tabel anak mengikuti order_ids di atas
    order_items = pd.read_sql(text(
        "SELECT * FROM raw.order_items WHERE order_id IN :ids"
    ).bindparams(ids=order_ids), conn)

    order_payments = pd.read_sql(text(
        "SELECT * FROM raw.order_payments WHERE order_id IN :ids"
    ).bindparams(ids=order_ids), conn)

    order_reviews = pd.read_sql(text(
        "SELECT * FROM raw.order_reviews WHERE order_id IN :ids"
    ).bindparams(ids=order_ids), conn)

    # 3. Customer, product, seller mengikuti apa yang muncul di atas
    customer_ids = tuple(orders["customer_id"])
    customers = pd.read_sql(text(
        "SELECT * FROM raw.customers WHERE customer_id IN :ids"
    ).bindparams(ids=customer_ids), conn)

    product_ids = tuple(order_items["product_id"].unique())
    products = pd.read_sql(text(
        "SELECT * FROM raw.products WHERE product_id IN :ids"
    ).bindparams(ids=product_ids), conn)

    seller_ids = tuple(order_items["seller_id"].unique())
    sellers = pd.read_sql(text(
        "SELECT * FROM raw.sellers WHERE seller_id IN :ids"
    ).bindparams(ids=seller_ids), conn)

    # 4. Tabel translation kecil, ambil semuanya
    translation = pd.read_sql(
        "SELECT * FROM raw.product_category_name_translation", conn)

frames = {
    "raw_orders": orders,
    "raw_order_items": order_items,
    "raw_order_payments": order_payments,
    "raw_order_reviews": order_reviews,
    "raw_customers": customers,
    "raw_products": products,
    "raw_sellers": sellers,
    "raw_product_category_name_translation": translation,
}

for name, df in frames.items():
    path = SEED_DIR / f"{name}.csv"
    df.to_csv(path, index=False)
    print(f"{name}: {len(df)} baris")