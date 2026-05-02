import os
import mysql.connector
from urllib.parse import quote_plus
from sqlalchemy import create_engine
from mysql.connector import Error
from dotenv import load_dotenv
from sqlalchemy.engine import URL


load_dotenv()

def get_connection():
    """
    Hàm trả về đối tượng kết nối MySQL. 
    Dùng cho các lệnh SQL thuần (INSERT, UPDATE, DELETE).
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS"),
            database=os.getenv("DB_NAME")
        )
        if connection.is_connected():
            print("Success")
            return connection
    except Error as e:
        print(f" Lỗi kết nối MySQL: {e}")
        return None

def get_sqlalchemy_engine():
    """
    Hàm trả về engine của SQLAlchemy.
    """
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASS")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    database = os.getenv("DB_NAME")

    # Mã hóa mật khẩu (biến @ thành %40, # thành %23...)
    # giúp SQLAlchemy không bao giờ nhầm lẫn mật khẩu với Host
    encoded_password = quote_plus(password)

    connection_string = f"mysql+mysqlconnector://{user}:{encoded_password}@{host}:{port}/{database}"
    
    engine = create_engine(connection_string)
    return engine

connector = get_connection();