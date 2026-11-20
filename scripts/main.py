
from extract import extract_data
from load import load_data


def run_pipeline():

    print("\n")
    print("================================")
    print(" E-COMMERCE ETL PIPELINE")
    print("================================")

    try:

        # STEP 1: EXTRACT
        data = extract_data()

        # STEP 2: LOAD
        load_data(data)

        print("\nPIPELINE EXECUTED SUCCESSFULLY!")

    except Exception as error:

        print("\nPIPELINE FAILED!")
        print(f"Error: {error}")

        raise


if __name__ == "__main__":
    run_pipeline()
