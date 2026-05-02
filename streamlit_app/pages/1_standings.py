import streamlit as st
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from db import GetStandings, GetLeagues, GetSeasons

st.set_page_config(page_title="Bảng xếp hạng", layout="wide")
st.title("Bảng Xếp Hạng")

col1, col2 = st.columns(2)
league = col1.selectbox("Giải đấu", GetLeagues())
season = col2.selectbox("Mùa giải", GetSeasons())

if st.button("Xem bảng xếp hạng"):
    df = GetStandings(league, season)

    if df.empty:
        st.warning("Không có dữ liệu.")
    else:
        # Tô màu hạng
        def highlight_rank(row):
            if row["rank"] <= 4:
                return ["background-color: #d4edda"] * len(row)  # xanh lá - top 4
            elif row["rank"] >= len(df) - 2:
                return ["background-color: #f8d7da"] * len(row)  # đỏ - relegation
            return [""] * len(row)

        st.dataframe(
            df.style.apply(highlight_rank, axis=1),
            use_container_width = True,
            hide_index = True
        )


