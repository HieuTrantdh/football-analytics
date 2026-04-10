use football_sql ;

delimiter $$

Create Procedure getTeam_5Matches_Result (
	IN p_team_id INT , 
    IN p_target_date DATETIME -- tim ket qua cua 5 tran truoc moc thoi gian nay 
)
Begin 
	Select 
		(Select	`name` from team where team_id = p_team_id  ) as team_name , 
        Round(AVG(match_points), 2 ) as gpa_last_5_match 
    from(
		select
		Case
			WHEN home_team_id = p_team_id AND home_score > away_score THEN 3
                WHEN home_team_id = p_team_id AND home_score = away_score THEN 1
                WHEN away_team_id = p_team_id AND away_score > home_score THEN 3
                WHEN away_team_id = p_team_id AND away_score = home_score THEN 1
                ELSE 0
            END AS match_points
        FROM matches
        WHERE (home_team_id = p_team_id OR away_team_id = p_team_id)
          AND status = 'Finished' 
          AND match_date < p_target_date -- lay cac tran truoc moc thoi gian nay 
        ORDER BY match_date DESC
        LIMIT 5    
    )	as recent_matches;
End$$ 
delimiter ;