import streamlit as st
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from db import GetFullStandings, GetPlayerRatings, GetSeasonSummary, GetLeagues

st.set_page_config(page_title="Thống Kê", layout="wide")
st.title("Thống Kê")
st.markdown("Trang này truy xuất dữ liệu trực tiếp từ 3 Views đã được tối ưu hóa dưới cơ sở dữ liệu.")

tab1, tab2, tab3 = st.tabs(["Bảng xếp hạng đầy đủ", "Rating Cầu thủ", "Tổng quan Mùa giải"])

# --- VIEW 1: BẢNG XẾP HẠNG ĐẦY ĐỦ ---
with tab1:
    st.subheader("Bảng Xếp Hạng Toàn Diện (vw_full_standings)")

    col1, col2 = st.columns(2)
    league = col1.selectbox("Giải đấu", ["Tất cả"] + GetLeagues(), key="tab1_league")

    if st.button("Lấy dữ liệu bảng xếp hạng"):
        df = GetFullStandings(league)

        if df.empty:
            st.warning("Không có dữ liệu.")
        else:
            def highlight_rank(row):
                if row["position"] <= 4:
                    return ["background-color: #d4edda"] * len(row)
                elif row["position"] >= len(df) - 2:
                    return ["background-color: #f8d7da"] * len(row)
                return [""] * len(row)

            st.dataframe(
                df.style.apply(highlight_rank, axis=1),
                use_container_width=True,
                hide_index=True
            )

# --- VIEW 2: RATING CẦU THỦ ---
with tab2:
    st.subheader("Tra cứu Rating Cầu Thủ (vw_player_ratings)")
    st.markdown("Nhập tên để tìm kiếm nhanh chỉ số cầu thủ qua các mùa giải.")

    col_search, col_btn = st.columns([4, 1])
    with col_search:
        player_name = st.text_input("Tên cầu thủ (VD: Messi, Ronaldo, Rooney):")
    with col_btn:
        st.write("")
        search_btn = st.button("Tra cứu")

    if search_btn and player_name:
        df = GetPlayerRatings(player_name)

        if df.empty:
            st.warning(f"Không tìm thấy cầu thủ nào tên là '{player_name}'.")
        else:
            st.success(f"Tìm thấy {len(df)} kết quả cho '{player_name}'")
            st.dataframe(df, use_container_width=True, hide_index=True)

            # st.subheader("Overall Rating qua các mùa")
            # st.line_chart(df.set_index("season")["rating"])

# --- VIEW 3: TỔNG QUAN MÙA GIẢI ---
with tab3:
    st.subheader("So sánh các giải đấu (vw_season_summary)")

    if st.button("Tải báo cáo tổng quan", type="primary"):
        df = GetSeasonSummary()

        if df.empty:
            st.warning("Không có dữ liệu.")
        else:
            st.dataframe(df, use_container_width=True, hide_index=True)

