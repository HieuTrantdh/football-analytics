use football_db ; 


-- sp1 bang xep hang theo mua giai 
delimiter $$ 
create procedure GetStandings (
	in p_league_name varchar(100) , -- ten giai dau 
    in p_year  varchar(20) -- mua giai vi du nhu 2014/2015
)
begin 
    select 
	rank() over(order by st.points desc , (st.goals_for - st.goals_against ) desc , st.goals_for DESC  ) as `rank` , 
    t.`name` as team_name , 
    st.wins  as win_matches , 
    st.draws as draw_matches , 
    st.losses as lose_matches , 
    st.points as points , 
	st.goals_for as goals_scored,
    st.goals_against as goals_conceded ,
    (st.goals_for - st.goals_against) as goals_difference , 
    (st.wins + st.draws + st.losses) as total_match_play 
    
    from standings st 
    join team    t  on t.team_id     = st.team_id
	join season  s  on s.season_id   = st.season_id
	join league  l  on l.league_id   = s.league_id 
    where l.`name` = p_league_name COLLATE utf8mb4_unicode_ci -- them collate nay de ko bi loi dinh dang 
			and s.`year` = p_year COLLATE utf8mb4_unicode_ci
    order by `rank` ;        
end$$
delimiter ;

----------------------------------------------------------------------------------------------------------------------------
-- vd :  call football_db.GetStandings('England Premier League', '2015/2016'); 
-- sp3 top cau thu theo rating 
delimiter $$ 
create procedure GetTopPLayerBySeason(
  in p_season_year varchar(20)  , -- column year trong season 
  in p_top_n  int    -- top so cau thu muon truy xuat 
)
begin
	select 
		rank() over (order by ps.rating desc ) as `rank` , 
        p.full_name, 
        ps.goals , 
        ps.assists , 
		ps.yellow_cards,
		ps.red_cards,
		ps.minutes_played,
        ps.rating
        
        
        from player_stats ps 
        join player p  on p.player_id = ps.player_id 
        join season s on ps.season_id = s.season_id 
        where s.`year` = p_season_year  COLLATE utf8mb4_unicode_ci -- them collate nay 
        and ps.rating is not null 
        order by ps.rating desc 
        limit p_top_n ;
end$$
delimiter ; 

-- call football_db.GetTopPLayerBySeason('2015/2016', 10); season moi nhat chi den 2015/2016

-- sp2 lich su doi dau giua 2 doi 

delimiter $$ 
create procedure GetHeadToHead(
  IN p_team1_name VARCHAR(100),
  IN p_team2_name VARCHAR(100)
)

begin
	select 
	s.`year`  AS season,
    l.name    AS league,
    m.match_date,
    ht.`name`  AS home_team,
    at.`name`  AS away_team,
    m.home_score,
    m.away_score,
    CASE
	WHEN m.home_score > m.away_score  THEN ht.name
	WHEN m.home_score < m.away_score  THEN at.name
	ELSE 'Draw'
	END AS result , 
    m.status 
    from matches m 
    JOIN team   ht ON ht.team_id   = m.home_team_id
	JOIN team   at ON at.team_id   = m.away_team_id
	JOIN season  s ON s.season_id  = m.season_id
	JOIN league  l ON l.league_id  = s.league_id
	WHERE (ht.name COLLATE utf8mb4_unicode_ci = p_team1_name COLLATE utf8mb4_unicode_ci 
       AND at.name COLLATE utf8mb4_unicode_ci = p_team2_name COLLATE utf8mb4_unicode_ci)
		OR (ht.name COLLATE utf8mb4_unicode_ci = p_team2_name COLLATE utf8mb4_unicode_ci 
       AND at.name COLLATE utf8mb4_unicode_ci = p_team1_name COLLATE utf8mb4_unicode_ci)
	ORDER BY m.match_date DESC;
    
end$$
delimiter ; 

-- vd  CALL GetHeadToHead('Arsenal', 'Chelsea');

--------------------------------
-- sp4 lich su doi qua cac mua 
DELIMITER $$

CREATE PROCEDURE GetTeamHistory(
  IN p_team_name VARCHAR(100)
)
BEGIN
  SELECT
    s.year                                       AS season,
    l.name                                       AS league,
    RANK() OVER (
      PARTITION BY s.season_id
      ORDER BY st.points DESC, (st.goals_for - st.goals_against) DESC
    )                                            AS final_rank,
    st.wins                                      AS W,
    st.draws                                     AS D,
    st.losses                                    AS L,
    st.points                                    AS Pts,
    st.goals_for                                 AS GF,
    st.goals_against                             AS GA,
    (st.goals_for - st.goals_against)            AS GD,
    (st.wins + st.draws + st.losses)             AS MP
  FROM standings st
  JOIN team   t ON t.team_id    = st.team_id
  JOIN season s ON s.season_id  = st.season_id
  JOIN league l ON l.league_id  = s.league_id
  WHERE t.name  = p_team_name COLLATE utf8mb4_unicode_ci
  ORDER BY s.year ASC;
END$$

DELIMITER ;

-- vd  CALL GetTeamHistory('Barcelona') ;
-- vd call football_db.GetTeamHistory('Manchester City');

