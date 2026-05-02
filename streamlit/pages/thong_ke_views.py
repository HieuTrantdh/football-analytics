# File: streamlit/pages/4_thong_ke_views.py
import streamlit as st
import pandas as pd
from utils.db_utils import get_connection

st.set_page_config(page_title="Thống Kê Chuyên Sâu", page_icon="📈", layout="wide")

st.title("📈 Thống Kê Chuyên Sâu (Sử dụng MySQL Views)")
st.markdown("Trang này truy xuất dữ liệu trực tiếp từ 3 Views đã được tối ưu hóa dưới cơ sở dữ liệu.")

# Hàm hỗ trợ gọi View siêu gọn (tái sử dụng nhiều lần)
def query_view(sql_query, params=None):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(sql_query, params)
            result = cursor.fetchall()
            return pd.DataFrame(result) if result else pd.DataFrame()
        except Exception as e:
            st.error(f"Lỗi truy vấn SQL: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()
    return pd.DataFrame()

# ---------------------------------------------------------
# SỬ DỤNG TABS ĐỂ GỘP 3 VIEWS VÀO 1 TRANG (Mẹo ăn điểm UI/UX)
# ---------------------------------------------------------
tab1, tab2, tab3 = st.tabs(["🏆 Bảng xếp hạng đầy đủ", "⭐ Rating Cầu thủ", "📊 Tổng quan Mùa giải"])

# --- VIEW 1: BẢNG XẾP HẠNG ĐẦY ĐỦ ---
with tab1:
    st.subheader("Bảng Xếp Hạng Toàn Diện (vw_full_standings)")
    league_filter = st.selectbox(
        "Lọc theo giải đấu:", 
        ["Tất cả", "England Premier League", "Spain LIGA BBVA", "Germany 1. Bundesliga", "Italy Serie A"]
    )
    
    if st.button("Lấy dữ liệu bảng xếp hạng"):
        if league_filter == "Tất cả":
            # Hạn chế lấy 500 dòng đầu để app không bị lag
            df_standings = query_view("SELECT * FROM vw_full_standings LIMIT 500") 
        else:
            df_standings = query_view("SELECT * FROM vw_full_standings WHERE league_name = %s", (league_filter,))
        
        if not df_standings.empty:
            st.dataframe(df_standings, use_container_width=True, hide_index=True)
        else:
            st.warning("Không có dữ liệu.")

# --- VIEW 2: RATING CẦU THỦ ---
with tab2:
    st.subheader("Tra cứu Rating Cầu Thủ (vw_player_ratings)")
    st.markdown("Nhập tên để tìm kiếm nhanh chỉ số cầu thủ qua các mùa giải.")
    
    col_search, col_btn = st.columns([4, 1])
    with col_search:
        player_name = st.text_input("Tên cầu thủ (VD: Messi, Ronaldo, Rooney):")
    with col_btn:
        st.write("") # Căn chỉnh nút bấm cho ngang hàng với ô nhập
        search_btn = st.button("🔍 Tra cứu")
        
    if search_btn and player_name:
        # Dùng LIKE để tìm kiếm gần đúng
        sql = "SELECT * FROM vw_player_ratings WHERE player_name LIKE %s ORDER BY season DESC"
        df_players = query_view(sql, (f"%{player_name}%",))
        
        if not df_players.empty:
            st.success(f"Tìm thấy {len(df_players)} kết quả cho '{player_name}'")
            st.dataframe(df_players, use_container_width=True, hide_index=True)
        else:
            st.warning(f"Không tìm thấy cầu thủ nào tên là '{player_name}'.")

# --- VIEW 3: TỔNG QUAN MÙA GIẢI ---
with tab3:
    st.subheader("So sánh các giải đấu (vw_season_summary)")
    
    if st.button("Tải báo cáo tổng quan", type="primary"):
        df_summary = query_view("SELECT * FROM vw_season_summary ORDER BY Season_Year DESC")
        
        if not df_summary.empty:
            st.dataframe(df_summary, use_container_width=True, hide_index=True)
            
            # Thêm một biểu đồ nho nhỏ để giáo viên lác mắt
            st.divider()
            st.markdown("#### 📊 Biểu đồ so sánh số bàn thắng (Top 10)")
            chart_data = df_summary[['League_Name', 'Total_goals']].head(10).set_index('League_Name')
            st.bar_chart(chart_data)
        else:
            st.warning("Không có dữ liệu.")