USE football_db;

CREATE OR REPLACE VIEW vw_flexible_standings AS
WITH raw_stats AS (
    -- Dữ liệu đội nhà
    SELECT m.home_team_id AS t_id, m.season_id, s.league_id,
        CASE WHEN m.home_score > m.away_score THEN 1 ELSE 0 END as w,
        CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END as d,
        CASE WHEN m.home_score < m.away_score THEN 1 ELSE 0 END as l,
        m.home_score as gf, m.away_score as ga
    FROM matches m 
    JOIN season s ON m.season_id = s.season_id 
    WHERE m.status = 'Finished'
    
    UNION ALL
    
    -- Dữ liệu đội khách
    SELECT m.away_team_id AS t_id, m.season_id, s.league_id,
        CASE WHEN m.away_score > m.home_score THEN 1 ELSE 0 END as w,
        CASE WHEN m.away_score = m.home_score THEN 1 ELSE 0 END as d,
        CASE WHEN m.away_score < m.home_score THEN 1 ELSE 0 END as l,
        m.away_score as gf, m.home_score as ga
    FROM matches m 
    JOIN season s ON m.season_id = s.season_id
    WHERE m.status = 'Finished'
)
SELECT 
    l.name AS League_Name,
    s.year AS Season_Year, 
    t.name AS Team,
    COUNT(*) as P, 
    SUM(w) as W, 
    SUM(d) as D, 
    SUM(l) as L,
    SUM(gf) as GF, 
    SUM(ga) as GA, 
    (SUM(gf) - SUM(ga)) as GD,
    (SUM(w) * 3 + SUM(d)) as Pts,
    rs.season_id, 
    rs.league_id
FROM raw_stats rs 
JOIN team t ON rs.t_id = t.team_id
JOIN season s ON rs.season_id = s.season_id
JOIN league l ON rs.league_id = l.league_id
GROUP BY rs.league_id, rs.season_id, rs.t_id, t.name, s.year, l.name
ORDER BY rs.league_id, rs.season_id, Pts DESC, GD DESC;
