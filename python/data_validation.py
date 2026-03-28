from db_connection import get_sqlalchemy_engine
import pandas as pd

engine = get_sqlalchemy_engine()

def validate_data():
    tables = ['Match', 'Team', 'Player', 'PlayerStats'] # Các bảng chính
    print("--- KIỂM TRA SỐ LƯỢNG DÒNG ---")
    for table in tables:
        try:
            count = pd.read_sql(f"SELECT COUNT(*) as total FROM {table}", engine)
            print(f" Bảng {table}: {count['total'][0]} dòng.")
        except Exception as e:
            print(f" Bảng {table} chưa có dữ liệu hoặc lỗi: {e}")

if __name__ == "__main__":
    validate_data()