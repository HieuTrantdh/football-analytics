use football_sql ; 
-- liet ke cac tran dau san nha va san khac , cua doi bong (p_team_id) tai mua giai (p_season_id)
DELIMITER $$
CREATE PROCEDURE GetTeamMatchesBySeason(
    IN p_team_id INT, 
    IN p_season_id INT
)
Begin
    Select
        m.match_date,
        ht.name AS home_team,
        m.home_score,
        m.away_score,
        at.name AS away_team,
        m.status
    FROM matches m
    JOIN team ht ON m.home_team_id = ht.team_id
    JOIN team at ON m.away_team_id = at.team_id
    WHERE (m.home_team_id = p_team_id or m.away_team_id = p_team_id)
      and m.season_id = p_season_id
    ORDER BY m.match_date Desc ;
End $$
DELIMITER ; 
-- o day ht va at la bi danh at : away_team  ;  ht : home_team  






-- tim kiem nhung cau thu tre nhat theo tuoi 
DELIMITER $$

CREATE PROCEDURE GetYoungestPlayers (
    IN p_limit INT -- so luong cau thu muon tim kiem 
)
BEGIN
    SELECT 
        full_name AS PlayerName,
        birth_date AS DateOfBirth,
        height AS Height_cm,
        weight AS Weight_lbs
    FROM 
        player
    WHERE 
        birth_date IS NOT NULL
    ORDER BY 
        birth_date DESC -- birthdate o day desc boi vi gan so voi hien tai nhat nen tuoi se giam dan 
    LIMIT p_limit;
END $$

DELIMITER ;


-- ------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE GetTopScoringMatches (
    IN p_limit INT
)
BEGIN
    SELECT  -- ở đây dùng alias ht = home_team và at = away team 
        m.match_date AS MatchDate,
        ht.name AS HomeTeam,
        m.home_score AS HomeScore,
        m.away_score AS AwayScore,
        at.name AS AwayTeam,
        (m.home_score + m.away_score) AS TotalGoals -- Tính tổng bàn thắng
    FROM 
        matches m
    JOIN 
        team ht ON m.home_team_id = ht.team_id
    JOIN 
        team at ON m.away_team_id = at.team_id
    ORDER BY 
        TotalGoals DESC
    LIMIT p_limit;
END $$
DELIMITER ;



