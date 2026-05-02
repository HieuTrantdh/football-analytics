import streamlit as st
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from db import GetHeadToHead, GetTeams

st.set_page_config(page_title="Lịch sử đối đầu", layout="wide")
st.title("Lịch Sử Đối Đầu")

col1, col2 = st.columns(2)
teams = GetTeams()
team1 = col1.selectbox("Đội 1", teams, index=0)
team2 = col2.selectbox("Đội 2", teams, index=1)

if st.button("So sánh"):
    if team1 == team2:
        st.warning("Vui lòng chọn 2 đội khác nhau.")
    else:
        df = GetHeadToHead(team1, team2)

        if df.empty:
            st.info("Hai đội chưa từng gặp nhau.")
        else:
            # Tính thống kê
            t1_wins = len(df[df["home_team"] == team1][df["home_score"] > df["away_score"]]) + \
                      len(df[df["away_team"] == team1][df["away_score"] > df["home_score"]])
            t2_wins = len(df[df["home_team"] == team2][df["home_score"] > df["away_score"]]) + \
                      len(df[df["away_team"] == team2][df["away_score"] > df["home_score"]])
            draws   = len(df) - t1_wins - t2_wins

            # Metric cards
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Tổng trận", len(df))
            c2.metric(f"{team1} thắng", t1_wins)
            c3.metric("Hòa", draws)
            c4.metric(f"{team2} thắng", t2_wins)

            st.divider()
            st.subheader("Kết quả từng trận")
            st.dataframe(df, use_container_width=True, hide_index=True)

