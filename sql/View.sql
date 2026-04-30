-- =========================================================
-- FILE: View.sql
-- Muc dich:
--   Chua cac view cua he thong football_db
-- Bao gom:
--   1. vw_full_standings
--   2. vw_player_ratings
--   3. vw_season_summary
-- =========================================================


USE football_db;

-- =========================================================
-- View 1: vw_full_standings
-- Muc dich:
--   Cho phep nguoi dung xem duoc bang xep hang 
-- Cach su dung:
--   Nguoi dung co the xem view bang league_name hoac season
-- =========================================================

DROP VIEW IF EXISTS vw_full_standings;

CREATE VIEW vw_full_standings AS
SELECT 
    
    RANK() OVER (
        PARTITION BY t.league_name, t.year 
        ORDER BY 
            SUM(t.points) DESC, 
            SUM(t.goals_for - t.goals_against) DESC, 
            SUM(t.goals_for) DESC
    ) AS position,
    
    t.league_name,
    t.year as season,
    team.name as team_name, 
    COUNT(*) AS matches_played,
    SUM(CASE WHEN t.points = 3 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN t.points = 1 THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN t.points = 0 THEN 1 ELSE 0 END) AS losses,
    SUM(t.goals_for) AS goals_for,
    SUM(t.goals_against) AS goals_against,
    SUM(t.goals_for - t.goals_against) AS goal_diff,
    SUM(t.points) AS total_points

FROM (
    -- Doi nha
    SELECT 
        l.name AS league_name,
        s.year,
        m.home_team_id AS team_id, 
        m.home_score AS goals_for,
        m.away_score AS goals_against,
        CASE 
            WHEN m.home_score > m.away_score THEN 3
            WHEN m.home_score = m.away_score THEN 1
            ELSE 0
        END AS points
    FROM matches m
        JOIN season s ON s.season_id = m.season_id
        JOIN league l ON l.league_id = s.league_id

    UNION ALL

    -- Doi khach
    SELECT 
        l.name AS league_name,
        s.year,
        m.away_team_id AS team_id, 
        m.away_score AS goals_for,
        m.home_score AS goals_against,
        CASE 
            WHEN m.away_score > m.home_score THEN 3
            WHEN m.away_score = m.home_score THEN 1
            ELSE 0
        END AS points
    FROM matches m
        JOIN season s ON s.season_id = m.season_id
        JOIN league l ON l.league_id = s.league_id
) AS t

JOIN team ON team.team_id = t.team_id

GROUP BY 
    t.league_name, 
    t.year, 
    t.team_id,   
    team.name
    
ORDER BY season ASC, total_points DESC;

-- Vi du su dung:
-- SELECT * FROM football_db.vw_standings
-- WHERE league_name = 'England Premier League';




-- =========================================================
-- View 2: vw_player_ratings
-- Mục đích:
--    Quan sát được chỉ số cầu thủ qua từng mùa
-- Cách sử dụng:
--   Có thể gọi truy vấn bằng tên cầu thủ hoặc giải đấu
-- =========================================================

DROP VIEW IF EXISTS vw_player_ratings;

CREATE VIEW vw_player_ratings AS
SELECT
    p.full_name  AS player_name,
    p.birth_date,
    l.name       AS league_name,
    s.year       AS season,
    ps.rating

FROM player p
    JOIN player_stats ps ON ps.player_id = p.player_id
    JOIN season s ON s.season_id = ps.season_idJOIN league l ON l.league_id = s.league_id

WHERE ps.rating IS NOT NULL

GROUP BY
    p.full_name,
    p.birth_date,
    l.name,
    s.year,
    ps.rating;

-- Ví dụ sử dụng: 
-- SELECT * FROM football_db.vw_player_ratings
-- WHERE player_name = 'Aaron Cresswell';




-- =========================================================
-- View 3: vw_season_summary
-- Mục đích:
--      Quan sát/ So sánh tổng quát các chỉ số của các 
--      giải đấu qua từng mùa/ tất cả các mùa   
-- Cách sử dụng:
--      Gọi truy vấn bằng tên giải đấu/ mùa
-- =========================================================

DROP VIEW IF EXISTS vw_season_summary;

CREATE OR REPLACE VIEW vw_season_summary AS
SELECT 
    l.name AS League_Name,
    s.year AS Season_Year,
    -- Đếm số đội tham gia dựa trên ID đội nhà duy nhất
    COUNT(DISTINCT m.home_team_id) AS Total_teams,
    -- Đếm tổng số trận đấu diễn ra
    COUNT(m.match_id) AS Total_matches,
    -- Tổng số bàn thắng sân nhà và sân khách
    SUM(m.home_score + m.away_score) AS Total_goals,
    -- Trung bình bàn thắng mỗi trận
    ROUND(AVG(m.home_score + m.away_score), 2) AS Avg_Goals,
    -- Trận đấu có tổng tỉ số cao nhất
    MAX(m.home_score + m.away_score) AS Max_goals

FROM league l
    JOIN season s ON l.league_id = s.league_id
    JOIN matches m ON s.season_id = m.season_id

WHERE m.status = 'Finished'

GROUP BY l.league_id, s.season_id, l.name, s.year;

-- Ví dụ sử dụng:
-- SELECT * FROM football_db.vw_season_summary
-- WHERE League_Name = 'England Premier League' AND Season_Year = '2011/2012'
-- 	OR League_name = 'Spain LIGA BBVA' AND Season_Year = '2011/2012';
