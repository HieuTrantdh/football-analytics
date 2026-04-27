USE football_db;

DELIMITER $$

-- =========================================================
-- SP1: Bang xep hang theo mua giai
-- =========================================================

DROP PROCEDURE IF EXISTS GetStandings $$

CREATE PROCEDURE GetStandings(
    IN p_league_name VARCHAR(100), -- ten giai dau
    IN p_year VARCHAR(20)          -- mua giai, vi du: 2014/2015
)
BEGIN
    SELECT
        (
            SELECT 1 + COUNT(*)
            FROM standings st2
            WHERE st2.season_id = st.season_id
              AND (
                    st2.points > st.points
                    OR (
                        st2.points = st.points
                        AND (st2.goals_for - st2.goals_against) > (st.goals_for - st.goals_against)
                    )
                    OR (
                        st2.points = st.points
                        AND (st2.goals_for - st2.goals_against) = (st.goals_for - st.goals_against)
                        AND st2.goals_for > st.goals_for
                    )
              )
        ) AS `rank`,
        t.`name` AS team_name,
        st.wins AS win_matches,
        st.draws AS draw_matches,
        st.losses AS lose_matches,
        st.points AS points,
        st.goals_for AS goals_scored,
        st.goals_against AS goals_conceded,
        (st.goals_for - st.goals_against) AS goals_difference,
        (st.wins + st.draws + st.losses) AS total_match_play
    FROM standings st
    JOIN team t
        ON t.team_id = st.team_id
    JOIN season s
        ON s.season_id = st.season_id
    JOIN league l
        ON l.league_id = s.league_id
    WHERE l.`name` = p_league_name COLLATE utf8mb4_unicode_ci
      AND s.`year` = p_year COLLATE utf8mb4_unicode_ci
    ORDER BY `rank`, team_name;
END $$

-- =========================================================
-- SP2: Top cau thu theo rating trong 1 mua giai
-- =========================================================

DROP PROCEDURE IF EXISTS GetTopPLayerBySeason $$

CREATE PROCEDURE GetTopPLayerBySeason(
    IN p_season_year VARCHAR(20), -- gia tri cua cot year trong bang season
    IN p_top_n INT                -- so cau thu muon truy xuat
)
BEGIN
    SELECT
        (
            SELECT 1 + COUNT(*)
            FROM player_stats ps2
            WHERE ps2.season_id = ps.season_id
              AND ps2.rating IS NOT NULL
              AND ps2.rating > ps.rating
        ) AS `rank`,
        p.full_name,
        ps.goals,
        ps.assists,
        ps.yellow_cards,
        ps.red_cards,
        ps.minutes_played,
        ps.rating
    FROM player_stats ps
    JOIN player p
        ON p.player_id = ps.player_id
    JOIN season s
        ON ps.season_id = s.season_id
    WHERE s.`year` = p_season_year COLLATE utf8mb4_unicode_ci
      AND ps.rating IS NOT NULL
    ORDER BY ps.rating DESC, p.full_name
    LIMIT p_top_n;
END $$

-- =========================================================
-- SP3: Lich su doi dau giua 2 doi
-- =========================================================

DROP PROCEDURE IF EXISTS GetHeadToHead $$

CREATE PROCEDURE GetHeadToHead(
    IN p_team1_name VARCHAR(100),
    IN p_team2_name VARCHAR(100)
)
BEGIN
    SELECT
        s.`year` AS season,
        l.`name` AS league,
        m.match_date,
        ht.`name` AS home_team,
        at.`name` AS away_team,
        m.home_score,
        m.away_score,
        CASE
            WHEN m.home_score > m.away_score THEN ht.`name`
            WHEN m.home_score < m.away_score THEN at.`name`
            ELSE 'Draw'
        END AS result,
        m.status
    FROM matches m
    JOIN team ht
        ON ht.team_id = m.home_team_id
    JOIN team at
        ON at.team_id = m.away_team_id
    JOIN season s
        ON s.season_id = m.season_id
    JOIN league l
        ON l.league_id = s.league_id
    WHERE (
              ht.`name` COLLATE utf8mb4_unicode_ci = p_team1_name COLLATE utf8mb4_unicode_ci
          AND at.`name` COLLATE utf8mb4_unicode_ci = p_team2_name COLLATE utf8mb4_unicode_ci
          )
       OR (
              ht.`name` COLLATE utf8mb4_unicode_ci = p_team2_name COLLATE utf8mb4_unicode_ci
          AND at.`name` COLLATE utf8mb4_unicode_ci = p_team1_name COLLATE utf8mb4_unicode_ci
          )
    ORDER BY m.match_date DESC;
END $$

-- =========================================================
-- SP4: Lich su cua 1 doi qua cac mua
-- =========================================================

DROP PROCEDURE IF EXISTS GetTeamHistory $$

CREATE PROCEDURE GetTeamHistory(
    IN p_team_name VARCHAR(100)
)
BEGIN
    SELECT
        s.`year` AS season,
        l.`name` AS league,
        (
            SELECT 1 + COUNT(*)
            FROM standings st2
            WHERE st2.season_id = st.season_id
              AND (
                    st2.points > st.points
                    OR (
                        st2.points = st.points
                        AND (st2.goals_for - st2.goals_against) > (st.goals_for - st.goals_against)
                    )
              )
        ) AS final_rank,
        st.wins AS W,
        st.draws AS D,
        st.losses AS L,
        st.points AS Pts,
        st.goals_for AS GF,
        st.goals_against AS GA,
        (st.goals_for - st.goals_against) AS GD,
        (st.wins + st.draws + st.losses) AS MP
    FROM standings st
    JOIN team t
        ON t.team_id = st.team_id
    JOIN season s
        ON s.season_id = st.season_id
    JOIN league l
        ON l.league_id = s.league_id
    WHERE t.`name` = p_team_name COLLATE utf8mb4_unicode_ci
    ORDER BY s.`year` ASC;
END $$

DELIMITER ;

-- TEST

-- SP1: Bang xep hang theo mua giai
CALL football_db.GetStandings('England Premier League', '2015/2016');

-- SP2: Top cau thu theo rating trong 1 mua giai
CALL football_db.GetTopPLayerBySeason('2015/2016', 11);

-- SP3: Lich su doi dau giua 2 doi
CALL football_db.GetHeadToHead('Arsenal', 'Chelsea');

-- SP4: Lich su cua 1 doi qua cac mua
CALL football_db.GetTeamHistory('Chelsea');