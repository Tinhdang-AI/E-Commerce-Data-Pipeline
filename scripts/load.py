
from sqlalchemy import text

from db_connection import get_engine


def load_data(data):

    engine = get_engine()

    print("========== LOAD START ==========")

    # Create raw schema
    with engine.begin() as connection:

        connection.execute(
            text("CREATE SCHEMA IF NOT EXISTS raw")
        )

    # Load each DataFrame
    for table_name, df in data.items():

        df.to_sql(
            name=table_name,
            con=engine,
            schema="raw",
            if_exists="replace",
            index=False,
            chunksize=5000
        )

        print(
            f"Loaded {table_name}: {len(df)} rows"
        )

    print("\n========== LOAD COMPLETED ==========")

    # Verify row counts
    with engine.connect() as connection:

        for table_name in data.keys():

            query = text(
                f'SELECT COUNT(*) FROM raw."{table_name}"'
            )

            count = connection.execute(query).scalar()

            print(f"{table_name}: {count} rows")

    engine.dispose()


if __name__ == "__main__":
    print("Please run through main.py")
    