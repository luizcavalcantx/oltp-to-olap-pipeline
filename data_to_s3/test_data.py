import os
from datetime import date
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

engine = create_engine(os.getenv("DATABASE_URL"))

database = ['customers','geolocation','order_items','order_payments','order_reviews','orders','products','sellers','product_category_name_translation']

today = date.today()

def validate_table(table):
    local_path = f"data_parquet/{table}_{today}.parquet"

    df_parquet = pd.read_parquet(local_path)
    df_postgres = pd.read_sql(f"select * from {table}", engine)

    rows_match = len(df_parquet) == len(df_postgres)
    cols_match = list(df_parquet.columns) == list(df_postgres.columns)

    status = "OK" if (rows_match and cols_match) else "MISMATCH"

    print(f"[{status}] {table}")
    print(f"  linhas -> parquet: {len(df_parquet)} | postgres: {len(df_postgres)}")
    print(f"  colunas batem: {cols_match}")
    if not rows_match or not cols_match:
        print(f"  colunas parquet: {list(df_parquet.columns)}")
        print(f"  colunas postgres: {list(df_postgres.columns)}")
    print()

if __name__ == '__main__':
    for table in database:
        validate_table(table)