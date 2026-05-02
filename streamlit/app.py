# File: streamlit/app.py
import streamlit as st
import pandas as pd
from utils.db_utils import get_connection

# 1. CẤU HÌNH TRANG (Bắt buộc phải đặt ở dòng code Streamlit đầu tiên)
st.set_page_config(
    page_title="Football Analytics - Nhóm 6",
    page_icon="⚽",
    layout="wide", # Dùng dàn trang rộng để hiển thị bảng dữ liệu đẹp hơn
    initial_sidebar_state="expanded"
)

# 2. XÂY DỰNG SIDEBAR (Menu bên trái)
with st.sidebar:
    st.image("https://cdn-icons-png.flaticon.com/512/1864/1864470.png", width=100)
    st.header("📌 Thông tin dự án")
    
    st.divider()
    st.caption("© 2026 Nhóm 6 - Chạy trên nền tảng Streamlit")

# 3. GIAO DIỆN CHÍNH (Trang chủ)
st.title("⚽ Hệ thống Phân tích Dữ liệu Bóng đá Châu Âu")
st.markdown("""
Chào mừng đến với trang tổng quan của dự án. Hệ thống này phân tích hơn 25.000 trận đấu từ 11 giải VĐQG Châu Âu, 
tích hợp trực tiếp với **MySQL** thông qua các **Stored Procedures** và **Views** tối ưu.
""")
st.divider()

# 4. TỐI ƯU HÓA BẰNG CACHE (Giúp app chạy nhanh, không query DB liên tục)
@st.cache_data(ttl=300) # Giữ data trong bộ nhớ tạm 5 phút
def get_dashboard_summary():
    conn = get_connection()
    if not conn:
        return None
        
    try:
        # Cấu hình dictionary=True để lấy data dưới dạng {cột: giá trị} dễ xử lý
        cursor = conn.cursor(dictionary=True)
        
        # MẸO ĂN ĐIỂM: Sau này bạn thay query này bằng cách gọi View 3 (vw_season_summary)
        # Tạm thời dùng query đếm tổng số trận đấu để test giao diện
        query = "SELECT COUNT(match_id) as total_matches FROM `matches`"
        cursor.execute(query)
        result = cursor.fetchone()
        return result
    except Exception as e:
        st.error(f"Lỗi truy vấn cơ sở dữ liệu: {e}")
        return None
    finally:
        # RẤT QUAN TRỌNG: Luôn phải đóng kết nối DB dù có lỗi hay không
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

# 5. HIỂN THỊ DỮ LIỆU TỔNG QUAN
st.subheader("📊 Tổng quan hệ thống")

# Gọi hàm lấy data
summary_data = get_dashboard_summary()

if summary_data:
    # Chia màn hình làm 3 cột để đặt các con số Metric nổi bật
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric(label="🏆 Tổng số giải đấu", value="11") # Bạn có thể query DB để lấy số này
    with col2:
        st.metric(label="📅 Giai đoạn", value="2008 - 2016")
    with col3:
        # Format số có dấu phẩy (vd: 25,979) cho chuyên nghiệp
        st.metric(label="⚽ Tổng số trận đấu", value=f"{summary_data['total_matches']:,}")
        
    st.success("✅ Kết nối MySQL ổn định. Hãy chọn các chức năng ở menu bên trái để tra cứu!")
else:
    st.error("❌ Không thể kết nối MySQL. Vui lòng kiểm tra lại file `.env` hoặc xem database đã được bật chưa.")