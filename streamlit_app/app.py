import streamlit as st
import sys, os

current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, '..'))
if root_dir not in sys.path:
    sys.path.append(root_dir)

st.set_page_config(
    page_title="Football Analytics",
    layout="wide",
    initial_sidebar_state="expanded"
)

st.markdown("""
<style>
    .block-container { padding-top: 4rem; }
    .hero-title {
        font-size: 3.8rem;
        font-weight: 800;
        color: #1a1a2e;
        margin-bottom: 0.2rem;
        text-align: center;
    }
    .hero-sub {
        font-size: 1.1rem;
        color: #666;
        margin-bottom: 2rem;
        text-align: center;
    }
    .card-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 1rem;
        margin-top: 1.5rem;
    }
    .card {
        background: white;
        border: 1.5px solid #e8ecf0;
        border-radius: 14px;
        padding: 1.4rem 1.6rem;
        transition: box-shadow 0.2s;
    }
    .card:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .card-title {
        font-size: 1.05rem;
        font-weight: 600;
        color: #1a1a2e;
        margin-bottom: 0.3rem;
    }
    .card-sp {
        font-size: 0.78rem;
        font-family: monospace;
        background: #f0f4ff;
        color: #3366cc;
        padding: 2px 8px;
        border-radius: 6px;
        display: inline-block;
        margin-bottom: 0.5rem;
    }
    .card-sp-green {
        font-size: 0.78rem;
        font-family: monospace;
        background: #f0fff4;
        color: #1a7a3c;
        padding: 2px 8px;
        border-radius: 6px;
        display: inline-block;
        margin-bottom: 0.5rem;
    }
    .card-desc { font-size: 0.9rem; color: #555; line-height: 1.5; }
    .stat-row { display: flex; gap: 1rem; margin-top: 2rem; }
    .stat-box {
        flex: 1;
        background: #f8f9ff;
        border-radius: 10px;
        padding: 1rem 1.2rem;
        text-align: center;
    }
    .stat-num { font-size: 1.8rem; font-weight: 700; color: #3366cc; }
    .stat-lbl { font-size: 0.82rem; color: #888; margin-top: 2px; }
    .card-highlight {
        background: linear-gradient(135deg, #f0f4ff 0%, #e8f5e9 100%);
        border: 1.5px solid #c5d8ff;
        border-radius: 14px;
        padding: 1.4rem 1.6rem;
        transition: box-shadow 0.2s;
        grid-column: span 2;
    }
    .card-highlight:hover { box-shadow: 0 4px 20px rgba(51,102,204,0.12); }
    .card-highlight .card-title { font-size: 1.1rem; }
    .tag-row { display: flex; gap: 0.5rem; flex-wrap: wrap; margin-bottom: 0.5rem; }
</style>
""", unsafe_allow_html=True)

st.markdown('<p class="hero-title">Football Analytics</p>', unsafe_allow_html=True)
st.markdown('<p class="hero-sub">Phân tích dữ liệu bóng đá châu Âu · 2008–2016 · European Soccer Database</p>', unsafe_allow_html=True)

st.markdown("""
<div class="stat-row">
  <div class="stat-box"><div class="stat-num">11</div><div class="stat-lbl">Giải đấu</div></div>
  <div class="stat-box"><div class="stat-num">8</div><div class="stat-lbl">Mùa giải</div></div>
  <div class="stat-box"><div class="stat-num">25K+</div><div class="stat-lbl">Trận đấu</div></div>
  <div class="stat-box"><div class="stat-num">10K+</div><div class="stat-lbl">Cầu thủ</div></div>
</div>
""", unsafe_allow_html=True)

st.divider()
st.subheader("Chọn các chức năng sau từ sidebar bên trái")

st.markdown("""
<div class="card-grid">
  <div class="card">
    <div class="card-title">Bảng Xếp Hạng</div>
    <span class="card-sp">GetStandings</span>
    <div class="card-desc">Xem hạng, điểm, W/D/L, hiệu số bàn thắng của mọi đội trong một mùa giải bất kỳ.</div>
  </div>
  <div class="card">
    <div class="card-title">Đối Đầu Lịch Sử</div>
    <span class="card-sp">GetHeadToHead</span>
    <div class="card-desc">So sánh toàn bộ kết quả giữa 2 đội: thắng/hòa/thua, tỉ số từng trận qua các mùa.</div>
  </div>
  <div class="card">
    <div class="card-title">Top Cầu Thủ</div>
    <span class="card-sp">GetTopPlayersBySeason</span>
    <div class="card-desc">Xếp hạng top N cầu thủ có overall rating cao nhất trong một mùa giải cụ thể.</div>
  </div>
  <div class="card">
    <div class="card-title">Lịch Sử Đội Bóng</div>
    <span class="card-sp">GetTeamHistory</span>
    <div class="card-desc">Theo dõi hành trình một đội qua 8 mùa: hạng, điểm, số bàn thắng/thua mỗi năm.</div>
  </div>
  <div class="card-highlight">
    <div class="card-title">Thống Kê Chuyên Sâu</div>
    <div class="tag-row">
      <span class="card-sp-green">vw_full_standings</span>
      <span class="card-sp-green">vw_player_ratings</span>
      <span class="card-sp-green">vw_season_summary</span>
    </div>
    <div class="card-desc">
      Truy xuất trực tiếp từ <strong>3 MySQL Views</strong> đã được tối ưu hóa dưới cơ sở dữ liệu.<br>
      • <strong>Bảng xếp hạng đầy đủ</strong> — lọc theo giải, xem toàn bộ chỉ số W/D/L<br>
      • <strong>Rating cầu thủ</strong> — tra cứu theo tên, xem chỉ số qua các mùa<br>
      • <strong>Tổng quan mùa giải</strong> — so sánh số bàn thắng giữa các giải đấu kèm biểu đồ
    </div>
  </div>
</div>
""", unsafe_allow_html=True)