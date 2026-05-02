# File: streamlit/pages/3_so_sanh_doi.py
import streamlit as st
import pandas as pd
from utils.db_utils import get_connection

st.set_page_config(page_title="Lịch Sử Đối Đầu", page_icon="⚔️", layout="wide")

st.title("⚔️ Lịch Sử Đối Đầu (Head-to-Head)")
st.markdown("Tra cứu tất cả các trận đấu giữa 2 đội bóng thông qua **Stored Procedure `GetHeadToHead`**.")

col1, col2 = st.columns(2)

with col1:
    # Dùng text_input nhập tay cho nhanh, set mặc định là Arsenal và Chelsea để test
    team1 = st.text_input("🛡️ Tên Đội 1:", value="Arsenal")

with col2:
    team2 = st.text_input("🛡️ Tên Đội 2:", value="Chelsea")

st.divider()

if st.button("🔥 Xem Lịch Sử Chạm Trán", type="primary"):
    if not team1 or not team2:
        st.warning("Vui lòng nhập tên của cả 2 đội bóng!")
    else:
        conn = get_connection()
        if conn:
            try:
                cursor = conn.cursor(dictionary=True)
                
                # Gọi SP2 truyền vào tên 2 đội
                cursor.callproc('GetHeadToHead', (team1, team2))
                
                result_data = []
                for result in cursor.stored_results():
                    result_data = result.fetchall()
                
                if result_data:
                    df = pd.DataFrame(result_data)
                    st.success(f"✅ Lịch sử đối đầu giữa {team1} và {team2}")
                    st.dataframe(df, use_container_width=True, hide_index=True)
                else:
                    st.warning(f"⚠️ Không tìm thấy trận đấu nào giữa {team1} và {team2}. Hãy kiểm tra lại tên tiếng Anh của đội bóng.")
                    
            except Exception as e:
                st.error(f"Lỗi khi lấy dữ liệu: {e}")
            finally:
                cursor.close()
                conn.close()