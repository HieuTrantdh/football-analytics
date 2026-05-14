import pandas as pd
import streamlit as st
import os
import urllib.parse
import pymysql
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Nạp file .env
load_dotenv()

# ========================== KẾT NỐI DATABASE ==========================

@st.cache_resource(show_spinner="Đang kết nối Database...")
def get_engine():
    try:
        # 1. Lấy dữ liệu từ file .env
        user = os.getenv("DB_USER")
        raw_password = os.getenv("DB_PASSWORD")
        host = os.getenv("DB_HOST", "127.0.0.1")
        port = os.getenv("DB_PORT", "3306")
        db_name = os.getenv("DB_NAME")

        # 2. Dự phòng Streamlit Secrets
        if not all([user, raw_password, db_name]):
            try:
                if "database" in st.secrets:
                    db = st.secrets["database"]
                    user = db.get("user", user)
                    raw_password = db.get("password", raw_password)
                    host = db.get("host", host)
                    port = db.get("port", port)
                    db_name = db.get("database", db_name)
            except: pass

        if not all([user, raw_password, db_name]):
            st.error("Thiếu thông tin cấu hình Database!")
            return None

        # 3. Mã hóa mật khẩu để xử lý ký tự đặc biệt (@, #, *)
        safe_password = urllib.parse.quote_plus(raw_password)
        conn_string = f"mysql+pymysql://{user}:{safe_password}@{host}:{port}/{db_name}?charset=utf8mb4"

        return create_engine(
            conn_string,
            pool_size=5,
            max_overflow=10,
            pool_recycle=3600,
            pool_pre_ping=True
        )
    except Exception as e:
        st.error(f"Lỗi khởi tạo Engine: {e}")
        return None

# ========================== XỬ LÝ STORED PROCEDURE ==========================

def execute_stored_procedure(proc_name: str, params: tuple) -> pd.DataFrame:
    engine = get_engine()
    if engine is None:
        return pd.DataFrame()
    
    # Lấy kết nối thuần để chạy callproc
    raw_conn = engine.raw_connection()
    cursor = None
    try:
        #Dùng DictCursor của pymysql thay vì dictionary=True
        cursor = raw_conn.cursor(pymysql.cursors.DictCursor)
        cursor.callproc(proc_name, params)
        
        # Với PyMySQL, kết quả trả về nằm trực tiếp sau khi fetch
        results = cursor.fetchall()
        return pd.DataFrame(results)
    except Exception as e:
        st.error(f"Lỗi thực thi Procedure '{proc_name}': {e}")
        return pd.DataFrame()
    finally:
        if cursor: cursor.close()
        raw_conn.close()

# ========================== CÁC HÀM TRUY VẤN (GIỮ NGUYÊN LOGIC) ==========================

def GetStandings(league: str, year: str): return execute_stored_procedure("GetStandings", (league, year))
def GetHeadToHead(t1: str, t2: str): return execute_stored_procedure("GetHeadToHead", (t1, t2))
def GetTopPlayerBySeason(s: str, n: int): return execute_stored_procedure("GetTopPlayerBySeason", (s, n))
def GetTeamHistory(team: str): return execute_stored_procedure("GetTeamHistory", (team,))

@st.cache_data
def GetLeagues():
    engine = get_engine()
    if not engine: return []
    return pd.read_sql("SELECT DISTINCT name FROM league ORDER BY name", engine)["name"].tolist()

@st.cache_data
def GetSeasons():
    engine = get_engine()
    if not engine: return []
    return pd.read_sql("SELECT DISTINCT year FROM season ORDER BY year DESC", engine)["year"].tolist()

@st.cache_data
def GetTeams():
    engine = get_engine()
    if not engine: return []
    return pd.read_sql("SELECT DISTINCT name FROM team ORDER BY name", engine)["name"].tolist()

def GetFullStandings(league: str = "Tất cả"):
    engine = get_engine()
    if not engine: return pd.DataFrame()
    query = "SELECT * FROM vw_full_standings"
    if league != "Tất cả":
        query += " WHERE league_name = :league"
        return pd.read_sql(text(query), engine, params={"league": league})
    return pd.read_sql(text(query + " LIMIT 500"), engine)

def GetPlayerRatings(name: str):
    engine = get_engine()
    if not engine: return pd.DataFrame()
    return pd.read_sql(
        text("SELECT * FROM vw_player_ratings WHERE player_name LIKE :name ORDER BY season DESC"),
        engine, params={"name": f"%{name}%"}
    )

def GetSeasonSummary():
    engine = get_engine()
    if not engine: return pd.DataFrame()
    return pd.read_sql("SELECT * FROM vw_season_summary ORDER BY Season_Year DESC", engine)