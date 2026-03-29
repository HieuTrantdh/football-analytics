import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv


load_dotenv()

def get_connection():
    """
    Hàm trả về đối tượng kết nối MySQL. 
    Dùng cho các lệnh SQL thuần (INSERT, UPDATE, DELETE).
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS"),
            database=os.getenv("DB_NAME")
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f" Lỗi kết nối MySQL: {e}")
        return None

def get_sqlalchemy_engine():
    """
    Hàm trả về engine của SQLAlchemy.
    Dùng cho Pandas (df.to_sql hoặc pd.read_sql).
    """
    from sqlalchemy import create_engine
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASS")
    host = os.getenv("DB_HOST")
    db = os.getenv("DB_NAME")
    
    # Tạo chuỗi kết nối
    engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}/{db}")
    return engine