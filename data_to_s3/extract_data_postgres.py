import os
from datetime import date
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

from upload_to_s3 import upload_to_s3
from logger_config import setup_logger

load_dotenv()

logger = setup_logger("extarct_data_postgres")
engine = create_engine(os.getenv("DATABASE_URL"))

database = ['customers','geolocation','order_items','order_payments','order_reviews','orders','products','sellers','product_category_name_translation']

def save_to_parquet(df,table,today):
    local_path = f"data_parquet/{table}_{today}.parquet"
    df.to_parquet(local_path, index=False)
    return local_path

def build_s3_key(table,today):
    return f"raw/{table}/{table}_{today}.parquet"

def run(table):
    logger.info("Starting extraction")

    df = pd.read_sql(f"select * from {table}", engine)
    today = date.today()

    local_path = save_to_parquet(df,table,today)
    s3_key = build_s3_key(table,today)

    try:
        upload_to_s3(local_path, s3_key)
        logger.info(f"Successfully upload to S3: {s3_key}")
    except Exception as e:
        logger.error(f"Failed to upload to S3: {e}")
        raise
    

if __name__ == '__main__':
    for table in database:
        run(table)