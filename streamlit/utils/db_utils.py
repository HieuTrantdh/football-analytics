# File: streamlit/utils/db_utils.py
import os
import mysql.connector
import streamlit as st
from dotenv import load_dotenv

# Load các biến từ file .env vào hệ thống
load_dotenv()

def get_connection():
    """Hàm kết nối database dùng thông tin từ .env"""
    try:
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT", 3306)),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS")
        )
        return conn
    except Exception as e:
        st.error(f"Lỗi kết nối cơ sở dữ liệu: {e}")
        return None