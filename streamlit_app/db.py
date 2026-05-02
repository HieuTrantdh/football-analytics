import pandas as pd
import streamlit as st
import sys, os
from sqlalchemy import text

# Setup path
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, '..'))
if root_dir not in sys.path:
    sys.path.append(root_dir)

from python.db_connection import get_sqlalchemy_engine

@st.cache_resource
def get_engine():
    return get_sqlalchemy_engine()

def execute_stored_procedure(proc_name: str, params: tuple) -> pd.DataFrame:
    """
    Hàm helper dùng chung để gọi Stored Procedure và dọn dẹp buffer 
    nhằm tránh lỗi 'Commands out of sync'.
    """
    engine = get_engine()
    raw_conn = engine.raw_connection()
    try:
        # Dùng dictionary=True để cursor trả về dữ liệu dạng dict (khớp với DataFrame)
        cursor = raw_conn.cursor(dictionary=True)
        
        # Gọi procedure
        cursor.callproc(proc_name, params)
        
        # Đọc tất cả kết quả trả về để làm sạch kết nối
        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
            break  # Thường chúng ta chỉ lấy tập kết quả (result set) đầu tiên
            
        return pd.DataFrame(results)
    except Exception as e:
        st.error(f"Lỗi thực thi {proc_name}: {e}")
        return pd.DataFrame()
    finally:
        cursor.close()
        raw_conn.close()

# ── SP1: Bảng xếp hạng ──────────────────────────────────────────
def GetStandings(league: str, year: str) -> pd.DataFrame:
    return execute_stored_procedure("GetStandings", (league, year))

# ── SP2: Đối đầu trực tiếp ──────────────────────────────────────
def GetHeadToHead(team1: str, team2: str) -> pd.DataFrame:
    return execute_stored_procedure("GetHeadToHead", (team1, team2))

# ── SP3: Top cầu thủ ──────────────────────────────────────────
def GetTopPlayerBySeason(season: str, top_n: int) -> pd.DataFrame:
    return execute_stored_procedure("GetTopPlayerBySeason", (season, top_n))

# ── SP4: Lịch sử đội bóng ──────────────────────────────────────
def GetTeamHistory(team: str) -> pd.DataFrame:
    return execute_stored_procedure("GetTeamHistory", (team,))

# ── Các hàm bổ trợ (Dùng SELECT đơn giản nên vẫn dùng pd.read_sql được) ──
@st.cache_data
def GetLeagues() -> list:
    engine = get_engine()
    df = pd.read_sql("SELECT DISTINCT name FROM league ORDER BY name", engine)
    return df["name"].tolist()

@st.cache_data
def GetSeasons() -> list:
    engine = get_engine()
    df = pd.read_sql("SELECT DISTINCT year FROM season ORDER BY year DESC", engine)
    return df["year"].tolist()

@st.cache_data
def GetTeams() -> list:
    engine = get_engine()
    df = pd.read_sql("SELECT DISTINCT name FROM team ORDER BY name", engine)
    return df["name"].tolist()


# ── VIEW 1: Bảng xếp hạng đầy đủ ───────────────────────────────
def GetFullStandings(league: str = "Tất cả") -> pd.DataFrame:
    engine = get_engine()
    try:
        if league == "Tất cả":
            return pd.read_sql(
                "SELECT * FROM vw_full_standings LIMIT 500",
                engine
            )
        else:
            return pd.read_sql(
                "SELECT * FROM vw_full_standings WHERE league_name = %(league)s",
                engine,
                params={"league": league}
            )
    except Exception as e:
        st.error(f"Lỗi truy vấn vw_full_standings: {e}")
        return pd.DataFrame()
 
# ── VIEW 2: Rating cầu thủ ──────────────────────────────────────
def GetPlayerRatings(player_name: str) -> pd.DataFrame:
    engine = get_engine()
    try:
        return pd.read_sql(
            "SELECT * FROM vw_player_ratings WHERE player_name LIKE %(name)s ORDER BY season DESC",
            engine,
            params={"name": f"%{player_name}%"}
        )
    except Exception as e:
        st.error(f"Lỗi truy vấn vw_player_ratings: {e}")
        return pd.DataFrame()
 
# ── VIEW 3: Tổng quan mùa giải ──────────────────────────────────
def GetSeasonSummary() -> pd.DataFrame:
    engine = get_engine()
    try:
        return pd.read_sql(
            "SELECT * FROM vw_season_summary ORDER BY Season_Year DESC",
            engine
        )
    except Exception as e:
        st.error(f"Lỗi truy vấn vw_season_summary: {e}")
        return pd.DataFrame()