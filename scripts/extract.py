
import pandas as pd
from pathlib import Path

# Project root directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Raw data directory
RAW_DIR = BASE_DIR / "data" / "raw"

# Dataset mapping
FILES = {
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "customers": "olist_customers_dataset.csv",
    "products": "olist_products_dataset.csv",
    "payments": "olist_order_payments_dataset.csv"
}


def extract_data():

    data = {}

    print("========== EXTRACT START ==========")

    for table_name, filename in FILES.items():

        file_path = RAW_DIR / filename

        if not file_path.exists():
            raise FileNotFoundError(
                f"Missing file: {file_path}"
            )

        df = pd.read_csv(file_path, low_memory=False)

        data[table_name] = df

        print(f"\nTable: {table_name}")
        print(f"Rows: {df.shape[0]}")
        print(f"Columns: {df.shape[1]}")

    print("\n========== EXTRACT COMPLETED ==========")

    return data


if __name__ == "__main__":
    extract_data()
