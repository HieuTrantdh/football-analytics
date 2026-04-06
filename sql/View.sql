CREATE VIEW standings AS
SELECT 
    league_id,
    season,
    team_id,

    COUNT(*) AS matches_played,

    SUM(CASE WHEN points = 3 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN points = 1 THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN points = 0 THEN 1 ELSE 0 END) AS losses,

    SUM(goals_for) AS goals_for,
    SUM(goals_against) AS goals_against,
    SUM(goals_for - goals_against) AS goal_diff,

    SUM(points) AS total_points

FROM (
    SELECT 
        league_id,
        season,
        home_team_api_id AS team_id,
        home_team_goal AS goals_for,
        away_team_goal AS goals_against,
        CASE 
            WHEN home_team_goal > away_team_goal THEN 3
            WHEN home_team_goal = away_team_goal THEN 1
            ELSE 0
        END AS points
    FROM `match`

    UNION ALL

    SELECT 
        league_id,
        season,
        away_team_api_id AS team_id,
        away_team_goal AS goals_for,
        home_team_goal AS goals_against,
        CASE 
            WHEN away_team_goal > home_team_goal THEN 3
            WHEN away_team_goal = home_team_goal THEN 1
            ELSE 0
        END AS points
    FROM `match`
) AS t

GROUP BY league_id, season, team_id;

select * from standings;