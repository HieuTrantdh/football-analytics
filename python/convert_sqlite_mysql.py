import os
import sqlite3
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from dotenv import load_dotenv

# 1. Load cấu hình
load_dotenv()

# 2. Kết nối SQLite (Đảm bảo file database.sqlite nằm ở thư mục gốc)
sqlite_conn = sqlite3.connect('database.sqlite')

# 3. Tạo chuỗi kết nối an toàn
connection_url = URL.create(
    drivername="mysql+mysqlconnector",
    username=os.getenv("DB_USER") or "root",
    password=os.getenv("DB_PASS") or "",
    host=os.getenv("DB_HOST") or "localhost",
    database=os.getenv("DB_NAME") or "soccer_db"
)

engine = create_engine(connection_url)

def run_import():
    # Bỏ qua các bảng hệ thống của SQLite
    query = "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
    tables = pd.read_sql(query, sqlite_conn)
    
    if tables.empty:
        print("--- [ERROR] No tables found in SQLite file! ---")
        return

    for table_name in tables['name']:
        print(f"--> Processing table: {table_name}")
        try:
            df = pd.read_sql(f"SELECT * FROM {table_name}", sqlite_conn)
            
            # CHỈNH TẠI ĐÂY: Chuyển hết về chữ thường để tránh lỗi Windows
            new_name = table_name.lower() 
            if new_name == 'player_attributes': new_name = 'playerstats'
            
            # Ghi vào MySQL
            df.to_sql(new_name, con=engine, if_exists='replace', index=False, chunksize=500)
            print(f"    [OK] Done: {new_name}")
            
        except Exception as e:
            print(f"    [ERROR] Table {table_name} failed: {str(e)}")

if __name__ == "__main__":
    try:
        run_import()
        print("\n=== [SUCCESS] ALL DATA CONVERTED SUCCESSFULLY! ===")
    except Exception as e:
        print(f"\n=== [CRITICAL] Connection failed: {str(e)} ===")