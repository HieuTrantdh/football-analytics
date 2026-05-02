# File: streamlit/pages/1_bang_xep_hang.py
import streamlit as st
import pandas as pd
from utils.db_utils import get_connection

st.set_page_config(page_title="Bảng Xếp Hạng", page_icon="🏆", layout="wide")

st.title("🏆 Bảng Xếp Hạng Giải Đấu")
st.markdown("Tra cứu bảng xếp hạng theo từng mùa giải. Dữ liệu được trích xuất trực tiếp từ Stored Procedure `GetStandings`.")

# 1. TẠO GIAO DIỆN CHỌN BỘ LỌC (Dùng 2 cột cho đẹp)
col1, col2 = st.columns(2)

# TẠO KHUNG CONTAINER CÓ VIỀN CHO BỘ LỌC
with st.container(border=True):
    st.markdown("##### 🔍 Bộ lọc dữ liệu") # Thêm dòng tiêu đề nhỏ cho chuyên nghiệp
    col1, col2 = st.columns(2)
    
    with col1:
        league_name = st.selectbox(
            "⚽ Chọn Giải Đấu:",
            ["England Premier League", "Spain LIGA BBVA", "Germany 1. Bundesliga", "Italy Serie A", "France Ligue 1"]
        )
    with col2:
        season_year = st.selectbox(
            "📅 Chọn Mùa Giải:",
            ["2008/2009", "2009/2010", "2010/2011", "2011/2012", "2012/2013", "2013/2014", "2014/2015", "2015/2016"]
        )

st.divider()

# 2. XỬ LÝ NÚT BẤM VÀ GỌI STORED PROCEDURE
if st.button("🔍 Xem bảng xếp hạng", type="primary"):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            
            # GỌI STORED PROCEDURE (Yêu cầu quan trọng để lấy điểm)
            # Truyền 2 tham số: Tên giải đấu và Năm mùa giải
            cursor.callproc('GetStandings', (league_name, season_year))
            
            # Lấy kết quả từ SP trả về
            result_data = []
            for result in cursor.stored_results():
                result_data = result.fetchall()
            
            if result_data:
                # Chuyển data thành bảng Pandas để hiển thị lên Streamlit
                df = pd.DataFrame(result_data)
                
                # Có thể đổi tên cột lại cho thân thiện với người dùng (tùy thuộc vào SP của bạn)
                # df.columns = ['Hạng', 'Tên Đội', 'Thắng', 'Hòa', 'Thua', 'Điểm', 'Hiệu số']
                
                st.success(f"✅ Bảng xếp hạng {league_name} - Mùa {season_year}")
                # st.dataframe hiển thị bảng có thể cuộn và sắp xếp rất mượt
                st.dataframe(df, use_container_width=True, hide_index=True)
            else:
                st.warning("⚠️ Không tìm thấy dữ liệu cho giải đấu và mùa giải này.")
                
        except Exception as e:
            st.error(f"Lỗi khi lấy dữ liệu bảng xếp hạng: {e}")
        finally:
            cursor.close()
            conn.close()