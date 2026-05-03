import streamlit as st
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from db import GetTopPlayerBySeason, GetSeasons

st.set_page_config(page_title="Top cầu thủ", layout="wide")
st.title("Top Cầu Thủ Theo Mùa")

col1, col2 = st.columns([2, 1])
season = col1.selectbox("Mùa giải", GetSeasons())
top_n  = col2.slider("Số lượng cầu thủ", min_value=5, max_value=50, value=20, step=1)

if st.button("Xem danh sách"):
    df = GetTopPlayerBySeason(season, top_n)

    if df.empty:
        st.warning("Không có dữ liệu.")
    else:
        st.dataframe(df, use_container_width=True, hide_index=True)

    

