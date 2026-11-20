
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

# Load environment variables
load_dotenv()

# Database configuration
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT", 5432)),
    "database": os.getenv("DB_NAME"),
    "username": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}


def get_engine():

    url = URL.create(
        drivername="postgresql+psycopg2",
        username=DB_CONFIG["username"],
        password=DB_CONFIG["password"],
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"],
        database=DB_CONFIG["database"]
    )

    engine = create_engine(url)

    return engine


def test_connection():

    engine = get_engine()

    with engine.connect() as connection:

        result = connection.execute(
            text("SELECT current_database(), version()")
        )

        print("PostgreSQL connected successfully!")

        for row in result:
            print(row)


if __name__ == "__main__":
    test_connection()
