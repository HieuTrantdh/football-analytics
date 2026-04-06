USE football_db;

-- =========================================================
-- PHAN 1: TAO TRIGGER
-- =========================================================

-- Trigger 1: Khong cho doi nha = doi khach
DROP TRIGGER IF EXISTS before_match_insert;

DELIMITER $$

CREATE TRIGGER before_match_insert
BEFORE INSERT ON `match`
FOR EACH ROW
BEGIN
    IF NEW.home_team_id = NEW.away_team_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi: home_team_id va away_team_id khong duoc trung nhau';
    END IF;
END$$

DELIMITER ;


-- Trigger 2: Tu dong cap nhat standings khi them tran finished
DROP TRIGGER IF EXISTS after_match_insert;

DELIMITER $$

CREATE TRIGGER after_match_insert
AFTER INSERT ON `match`
FOR EACH ROW
BEGIN
    IF NEW.status = 'finished' THEN

        INSERT INTO standings (
            team_id, season_id, wins, draws, losses,
            points, goals_for, goals_against
        )
        VALUES (NEW.home_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0)
        ON DUPLICATE KEY UPDATE standing_id = standing_id;

        INSERT INTO standings (
            team_id, season_id, wins, draws, losses,
            points, goals_for, goals_against
        )
        VALUES (NEW.away_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0)
        ON DUPLICATE KEY UPDATE standing_id = standing_id;

        IF NEW.home_score > NEW.away_score THEN

            UPDATE standings
            SET wins = wins + 1,
                points = points + 3,
                goals_for = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET losses = losses + 1,
                goals_for = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        ELSEIF NEW.home_score = NEW.away_score THEN

            UPDATE standings
            SET draws = draws + 1,
                points = points + 1,
                goals_for = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET draws = draws + 1,
                points = points + 1,
                goals_for = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        ELSE

            UPDATE standings
            SET losses = losses + 1,
                goals_for = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET wins = wins + 1,
                points = points + 3,
                goals_for = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        END IF;

    END IF;
END$$

DELIMITER ;

