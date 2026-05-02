# File: streamlit/pages/2_cau_thu.py
import streamlit as st
import pandas as pd
from utils.db_utils import get_connection

st.set_page_config(page_title="Top Cầu Thủ", page_icon="🏃", layout="wide")

st.title("🏃 Top Cầu Thủ Theo Mùa Giải")
st.markdown("Sử dụng **Stored Procedure `GetTopPlayersBySeason`** để lọc ra những cầu thủ có rating cao nhất.")

col1, col2 = st.columns(2)

with col1:
    season_year = st.selectbox(
        "📅 Chọn Mùa Giải:",
        ["2008/2009", "2009/2010", "2010/2011", "2011/2012", "2012/2013", "2013/2014", "2014/2015", "2015/2016"]
    )

with col2:
    # Dùng slider để người dùng kéo chọn số lượng hiển thị (10, 20, 30...)
    top_n = st.slider("🏅 Số lượng Top:", min_value=10, max_value=50, value=20, step=10)

st.divider()

if st.button("🔍 Lọc danh sách", type="primary"):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            # Gọi SP3 truyền vào mùa giải và số lượng Top N
            cursor.callproc('GetTopPlayersBySeason', (season_year, top_n))
            
            result_data = []
            for result in cursor.stored_results():
                result_data = result.fetchall()
            
            if result_data:
                df = pd.DataFrame(result_data)
                
                # Highlight các dòng dữ liệu để bảng nhìn pro hơn
                st.success(f"✅ Đã tải danh sách Top {top_n} cầu thủ mùa {season_year}")
                # CẤU HÌNH CỘT NÂNG CAO CHO DATAFRAME
                st.dataframe(
                    df,
                    use_container_width=True,
                    hide_index=True,
                    column_config={
                        # 1. Biến cột rating thành thanh Progress Bar màu sắc
                        "rating": st.column_config.ProgressColumn(
                            "Rating", # Tên cột hiển thị
                            help="Điểm đánh giá phong độ từ 50 đến 100",
                            format="%.2f",
                            min_value=50, 
                            max_value=100,
                        ),
                        # 2. Thêm icon vào các cột số liệu cho sinh động
                        "minutes_played": st.column_config.NumberColumn(
                            "Số phút",
                            format="%d ⏱️" 
                        ),
                        "goals": st.column_config.NumberColumn(
                            "Bàn thắng",
                            format="%d ⚽"
                        ),
                        "assists": st.column_config.NumberColumn(
                            "Kiến tạo",
                            format="%d 👟"
                        ),
                        # 3. Chỉnh lại tên cột thông thường cho đẹp
                        "rank": "Hạng",
                        "full_name": "Tên Cầu Thủ"
                    }
                )
            else:
                st.warning("⚠️ Không tìm thấy dữ liệu.")
                
        except Exception as e:
            st.error(f"Lỗi khi lấy dữ liệu: {e}")
        finally:
            cursor.close()
            conn.close()