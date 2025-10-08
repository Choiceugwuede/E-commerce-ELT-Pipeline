import os
import pandas as pd 
import logging
from sqlalchemy import create_engine,text

# set logging 
log_file = os.getenv("LOG_PATH")
level = logging.INFO

logging.basicConfig(format="%(asctime)s [%(levelname)s] %(message)s", level=level,
                    handlers=[
                        logging.FileHandler(log_file),
                        logging.StreamHandler()
                        ]
)

# Env variables from Docker Compose 
PG_HOST = os.getenv("PG_HOST")
PG_PORT = os.getenv("PG_PORT")
PG_USER = os.getenv("PG_USER")
PG_PASSWORD = os.getenv("PG_PASSWORD")
PG_DB = os.getenv("PG_DB")


# import csv
CSV_URL = os.getenv("CSV_URL")

# EXTRACT
def extract():
    """Extract CSV and save in pandas dataframe"""
    df = pd.read_csv(CSV_URL, encoding="latin1")
    logging.info(f"Extracted data: {df.head()}")
    return df

# LOAD
def load(df):
    """Load dataframe into postgres staging database using full load"""

    logging.info("Connecting to database....")
    engine = create_engine(f"postgresql://{PG_USER}:{PG_PASSWORD}@{PG_HOST}:{PG_PORT}/{PG_DB}")

    with engine.begin() as conn:
        try:
            conn.execute(text("TRUNCATE TABLE bankole_store;"))
        except Exception as e:
            logging.warning(f"Table bankole_store does not exist yet, skipping truncate. Details: {e}")

    df.to_sql("bankole_store", engine, if_exists="append", index=False)
    logging.info("Data successfully loaded into bankole_store")


if __name__ == "__main__":
    logging.info("Extract and load job started")
    try:
        data = extract() 
        load(data)
        logging.info("Extract and load job completed successfully")
    except Exception as e:
        logging.error(f"Extract and load job failed: {e}" , exc_info=True)