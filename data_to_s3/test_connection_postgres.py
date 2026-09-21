from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()

engine = create_engine(os.getenv("DATABASE_URL"))

with engine.connect() as conn:
    print("Conexao bem sucedida")
    response_query = conn.execute(text("select * from orders limit 5"))
    rows = response_query.fetchall()
    print(rows)