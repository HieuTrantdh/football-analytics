import streamlit as st
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from db import GetTeamHistory, GetTeams

st.set_page_config(page_title="Lịch sử đội", layout="wide")
st.title("Lịch Sử Đội Bóng")

team = st.selectbox("Chọn đội", GetTeams())

if st.button("Xem lịch sử"):
    df = GetTeamHistory(team)

    if df.empty:
        st.warning("Không có dữ liệu.")
    else:
        # Metric tóm tắt
        c1, c2, c3 = st.columns(3)
        c1.metric("Tổng mùa giải", len(df))
        c2.metric("Điểm cao nhất", df["Pts"].max())
        c3.metric("Hạng tốt nhất", df["final_rank"].min())

        # Bảng đầy đủ
        st.subheader("Bảng chi tiết")
        st.dataframe(df, use_container_width=True, hide_index=True)

