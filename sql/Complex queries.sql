-- ============================================================
-- sql/07_complex_queries.sql
-- Complex Queries: Window Functions + CTE
-- Dataset: football_db | European Soccer Database 2008-2016
-- ============================================================

-- ============================================================
-- QUERY 1 — RANK() OVER PARTITION BY
-- Xếp hạng đội bóng trong từng mùa giải, theo từng giải đấu
-- Kỹ thuật: RANK(), DENSE_RANK(), PARTITION BY
-- Mục đích: So sánh thứ hạng trong cùng bối cảnh (cùng giải,
--           cùng mùa) thay vì so sánh điểm tuyệt đối
-- ============================================================

SELECT
    l.name                                          AS league_name,
    s.year                                          AS season,
    t.name                                          AS team_name,
    st.points,
    st.wins,
    st.draws,
    st.losses,
    st.goals_for,
    st.goals_against,
    st.goals_for - st.goals_against                 AS goal_diff,
    RANK() OVER (
        PARTITION BY st.season_id
        ORDER BY st.points DESC,
                 (st.goals_for - st.goals_against) DESC
    )                                               AS rank_in_season,
    DENSE_RANK() OVER (
        PARTITION BY s.league_id, st.season_id
        ORDER BY st.points DESC
    )                                               AS rank_in_league
FROM standings st
JOIN team   t  ON st.team_id   = t.team_id
JOIN season s  ON st.season_id = s.season_id
JOIN league l  ON s.league_id  = l.league_id
WHERE s.year = '2015/2016'
ORDER BY l.name, rank_in_league;

-- Kết quả kỳ vọng:
-- Mỗi đội có thứ hạng riêng trong giải của mình (mùa 2015/2016)
-- RANK()       → bỏ qua số khi có đồng hạng (1,1,3,4...)
-- DENSE_RANK() → không bỏ qua số             (1,1,2,3...)
-- Hai cột này cho thấy sự khác biệt giữa 2 hàm xếp hạng


-- ============================================================
-- QUERY 2 — LAG() OVER PARTITION BY
-- So sánh điểm số mùa này với mùa trước của cùng một đội
-- Kỹ thuật: LAG(), LEAD(), PARTITION BY team_id ORDER BY season
-- Mục đích: Đo lường xu hướng — đội nào đang tiến bộ/xuống dốc
-- ============================================================

SELECT
    t.name                                              AS team_name,
    l.name                                              AS league_name,
    s.year                                              AS season,
    st.points                                           AS points_this_season,
    LAG(st.points, 1) OVER (
        PARTITION BY st.team_id
        ORDER BY s.start_date
    )                                                   AS points_last_season,
    st.points - LAG(st.points, 1) OVER (
        PARTITION BY st.team_id
        ORDER BY s.start_date
    )                                                   AS points_delta,
    CASE
        WHEN st.points - LAG(st.points, 1) OVER (
                PARTITION BY st.team_id ORDER BY s.start_date
             ) > 0  THEN '📈 Tăng'
        WHEN st.points - LAG(st.points, 1) OVER (
                PARTITION BY st.team_id ORDER BY s.start_date
             ) < 0  THEN '📉 Giảm'
        WHEN LAG(st.points, 1) OVER (
                PARTITION BY st.team_id ORDER BY s.start_date
             ) IS NULL THEN '— Mùa đầu'
        ELSE                   '➡️ Giữ nguyên'
    END                                                 AS trend,
    LEAD(st.points, 1) OVER (
        PARTITION BY st.team_id
        ORDER BY s.start_date
    )                                                   AS points_next_season
FROM standings st
JOIN team   t  ON st.team_id   = t.team_id
JOIN season s  ON st.season_id = s.season_id
JOIN league l  ON s.league_id  = l.league_id
ORDER BY t.name, s.start_date;

-- Kết quả kỳ vọng:
-- Mỗi dòng = 1 đội × 1 mùa, kèm điểm mùa trước và mùa sau
-- Dòng đầu tiên của mỗi đội có points_last_season = NULL (bình thường)
-- points_delta > 0  → đội đang tiến bộ
-- points_delta < 0  → đội đang xuống dốc
-- Có thể filter WHERE trend = '📉 Giảm' để tìm đội sa sút


-- ============================================================
-- QUERY 3 — SUM() OVER (ROWS UNBOUNDED PRECEDING)
-- Tổng bàn thắng tích lũy theo thời gian của từng đội
-- Kỹ thuật: SUM() OVER với frame ROWS UNBOUNDED PRECEDING
-- Mục đích: Thấy được trajectory — đội nào ghi bàn đều, đội
--           nào chỉ bùng phát ngắn rồi chững lại
-- ============================================================

WITH match_goals AS (
    -- Gom tất cả bàn thắng: cả lúc đá nhà lẫn đá khách
    SELECT
        home_team_id                AS team_id,
        match_date,
        home_score                  AS goals_scored,
        away_score                  AS goals_conceded,
        season_id
    FROM matches
    WHERE status = 'finished'
      AND home_score IS NOT NULL

    UNION ALL

    SELECT
        away_team_id                AS team_id,
        match_date,
        away_score                  AS goals_scored,
        home_score                  AS goals_conceded,
        season_id
    FROM matches
    WHERE status = 'finished'
      AND away_score IS NOT NULL
)
SELECT
    t.name                                              AS team_name,
    mg.match_date,
    mg.goals_scored,
    mg.goals_conceded,
    SUM(mg.goals_scored) OVER (
        PARTITION BY mg.team_id
        ORDER BY mg.match_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                   AS cumulative_goals_scored,
    SUM(mg.goals_conceded) OVER (
        PARTITION BY mg.team_id
        ORDER BY mg.match_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                   AS cumulative_goals_conceded,
    AVG(mg.goals_scored) OVER (
        PARTITION BY mg.team_id
        ORDER BY mg.match_date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    )                                                   AS avg_goals_last5_matches
FROM match_goals mg
JOIN team t ON mg.team_id = t.team_id
-- Lọc 1 đội để demo rõ ràng hơn, bỏ WHERE để xem toàn bộ
WHERE t.name = 'Manchester City'
ORDER BY mg.match_date;

-- Kết quả kỳ vọng:
-- cumulative_goals_scored  → tổng bàn thắng tích lũy từ đầu đến trận đó
-- cumulative_goals_conceded→ tổng bàn thua tích lũy
-- avg_goals_last5_matches  → trung bình động 5 trận gần nhất
--                            (sliding window — không thể làm bằng GROUP BY)
-- Dùng dữ liệu này vẽ line chart trong Jupyter rất đẹp


-- ============================================================
-- QUERY 4 — CTE (WITH ... AS)
-- Top đội nhất quán nhất qua nhiều mùa giải
-- Kỹ thuật: Multi-step CTE, kết hợp aggregate + window function
-- Mục đích: Tìm đội bóng duy trì phong độ cao LIÊN TỤC,
--           không chỉ xuất sắc 1 mùa rồi biến mất
-- ============================================================

WITH
-- Bước 1: Xếp hạng từng đội trong từng mùa (trong giải của họ)
team_rank_per_season AS (
    SELECT
        st.team_id,
        st.season_id,
        st.points,
        s.league_id,
        RANK() OVER (
            PARTITION BY s.league_id, st.season_id
            ORDER BY st.points DESC
        ) AS rank_in_league
    FROM standings st
    JOIN season s ON st.season_id = s.season_id
),

-- Bước 2: Đếm số mùa mỗi đội lọt top 3 trong giải của mình
top3_count AS (
    SELECT
        team_id,
        league_id,
        COUNT(*)                        AS seasons_in_top3,
        AVG(points)                     AS avg_points,
        MIN(rank_in_league)             AS best_rank_ever,
        MAX(rank_in_league)             AS worst_rank_in_top3
    FROM team_rank_per_season
    WHERE rank_in_league <= 3
    GROUP BY team_id, league_id
),

-- Bước 3: Tổng số mùa mỗi đội có mặt trong dataset
total_seasons AS (
    SELECT
        team_id,
        COUNT(DISTINCT season_id)       AS total_seasons_played
    FROM standings
    GROUP BY team_id
)

-- Bước 4: Kết hợp, tính tỷ lệ nhất quán, lấy top 10
SELECT
    t.name                                              AS team_name,
    l.name                                              AS league_name,
    tc.seasons_in_top3,
    ts.total_seasons_played,
    ROUND(
        tc.seasons_in_top3 * 100.0 / ts.total_seasons_played, 1
    )                                                   AS consistency_pct,
    ROUND(tc.avg_points, 1)                             AS avg_points,
    tc.best_rank_ever,
    tc.worst_rank_in_top3
FROM top3_count     tc
JOIN total_seasons  ts ON tc.team_id   = ts.team_id
JOIN team           t  ON tc.team_id   = t.team_id
JOIN league         l  ON tc.league_id = l.league_id
WHERE ts.total_seasons_played >= 4          -- chỉ tính đội có đủ dữ liệu
ORDER BY consistency_pct DESC, avg_points DESC
LIMIT 15;

-- Kết quả kỳ vọng:
-- consistency_pct = 100% → đội lọt top 3 MỌI mùa có mặt trong dataset
-- Kỳ vọng thấy: Barcelona, Bayern Munich, Juventus, PSG...
-- CTE giúp chia 4 bước rõ ràng thay vì 1 subquery lồng 4 cấp
-- Đây là pattern chuẩn trong data engineering thực tế


-- ============================================================
-- GHI CHÚ SỬ DỤNG
-- ============================================================
-- Q1: Chạy với WHERE s.year = '2015/2016', thử đổi sang năm khác
-- Q2: Bỏ filter để xem toàn bộ, thêm WHERE trend = '📉 Giảm'
--     để tìm các đội sa sút liên tiếp
-- Q3: Đổi tên đội trong WHERE t.name = '...' để xem đội khác
--     Gợi ý: 'Real Madrid CF', 'FC Barcelona', 'Bayern Munich'
-- Q4: Thay LIMIT 15 và WHERE rank_in_league <= 3 tùy mục đích
