USE football_db;

-- =========================================================
-- FILE: Triggers.sql
-- Muc dich:
--   Chua cac trigger chinh cua he thong football_db
-- Bao gom:
--   1. before_match_insert
--   2. after_match_insert
--   3. after_match_update
-- =========================================================



-- =========================================================
-- Trigger 1: before_match_insert
-- Muc dich:
--   Khong cho phep them tran dau neu doi nha = doi khach
-- Ly do:
--   MySQL khong cho dung CHECK(home_team_id <> away_team_id)
--   trong mot so truong hop co lien quan den foreign key
-- =========================================================

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



-- =========================================================
-- Trigger 2: after_match_insert
-- Muc dich:
--   Tu dong cap nhat bang standings khi them moi mot tran da ket thuc
-- Dieu kien:
--   Chi xu ly khi:
--     - NEW.status = 'finished'
--     - NEW.home_score IS NOT NULL
--     - NEW.away_score IS NOT NULL
-- =========================================================

DROP TRIGGER IF EXISTS after_match_insert;

DELIMITER $$

CREATE TRIGGER after_match_insert
AFTER INSERT ON `match`
FOR EACH ROW
BEGIN
    IF NEW.status = 'finished'
       AND NEW.home_score IS NOT NULL
       AND NEW.away_score IS NOT NULL THEN

        -- Tao dong standings cho doi nha neu chua co
        INSERT IGNORE INTO standings (
            team_id, season_id,
            wins, draws, losses,
            points, goals_for, goals_against
        )
        VALUES (NEW.home_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0);

        -- Tao dong standings cho doi khach neu chua co
        INSERT IGNORE INTO standings (
            team_id, season_id,
            wins, draws, losses,
            points, goals_for, goals_against
        )
        VALUES (NEW.away_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0);

        -- Truong hop doi nha thang
        IF NEW.home_score > NEW.away_score THEN

            UPDATE standings
            SET wins          = wins + 1,
                points        = points + 3,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET losses        = losses + 1,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        -- Truong hop hoa
        ELSEIF NEW.home_score = NEW.away_score THEN

            UPDATE standings
            SET draws         = draws + 1,
                points        = points + 1,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET draws         = draws + 1,
                points        = points + 1,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        -- Truong hop doi khach thang
        ELSE

            UPDATE standings
            SET losses        = losses + 1,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET wins          = wins + 1,
                points        = points + 3,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        END IF;

    END IF;
END$$

DELIMITER ;



-- =========================================================
-- Trigger 3: after_match_update
-- Muc dich:
--   Tu dong cap nhat bang standings khi mot tran dau
--   chuyen tu trang thai chua finished sang finished
-- Dieu kien:
--   Chi xu ly khi:
--     - OLD.status <> 'finished'
--     - NEW.status = 'finished'
--     - NEW.home_score IS NOT NULL
--     - NEW.away_score IS NOT NULL
-- =========================================================

DROP TRIGGER IF EXISTS after_match_update;

DELIMITER $$

CREATE TRIGGER after_match_update
AFTER UPDATE ON `match`
FOR EACH ROW
BEGIN
    IF OLD.status <> 'finished'
       AND NEW.status = 'finished'
       AND NEW.home_score IS NOT NULL
       AND NEW.away_score IS NOT NULL THEN

        -- Tao dong standings neu chua co
        INSERT IGNORE INTO standings (
            team_id, season_id,
            wins, draws, losses,
            points, goals_for, goals_against
        )
        VALUES
            (NEW.home_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0),
            (NEW.away_team_id, NEW.season_id, 0, 0, 0, 0, 0, 0);

        -- Truong hop doi nha thang
        IF NEW.home_score > NEW.away_score THEN

            UPDATE standings
            SET wins          = wins + 1,
                points        = points + 3,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET losses        = losses + 1,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        -- Truong hop hoa
        ELSEIF NEW.home_score = NEW.away_score THEN

            UPDATE standings
            SET draws         = draws + 1,
                points        = points + 1,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET draws         = draws + 1,
                points        = points + 1,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        -- Truong hop doi khach thang
        ELSE

            UPDATE standings
            SET losses        = losses + 1,
                goals_for     = goals_for + NEW.home_score,
                goals_against = goals_against + NEW.away_score
            WHERE team_id = NEW.home_team_id
              AND season_id = NEW.season_id;

            UPDATE standings
            SET wins          = wins + 1,
                points        = points + 3,
                goals_for     = goals_for + NEW.away_score,
                goals_against = goals_against + NEW.home_score
            WHERE team_id = NEW.away_team_id
              AND season_id = NEW.season_id;

        END IF;

    END IF;
END$$

DELIMITER ;

-- =========================================================
-- Trigger 4: before_player_stats_insert
-- Muc dich:
--   Tu dong cap nhat rating cau thu khi insert mot ban ghi moi
-- Dieu kien:
--   Xu ly trong moi truong hop insert vao player_stats
-- =========================================================

DROP TRIGGER IF EXISTS before_player_stats_insert;

DELIMITER $$

CREATE TRIGGER before_player_stats_insert
BEFORE INSERT ON player_stats
FOR EACH ROW
BEGIN
	SET NEW.rating = CASE
		WHEN ((NEW.goals*3 + NEW.assists) - (NEW.red_cards*3 + NEW.yellow_cards)*1.27) <= 0 THEN 0
		WHEN NEW.minutes_played = 0 THEN 0
		WHEN (NEW.goals*3 + NEW.assists)/NEW.minutes_played > 0.053 THEN
			IF((NEW.red_cards*3 + NEW.yellow_cards)/NEW.minutes_played > 0.011, 
					ROUND(((NEW.goals*3 + NEW.assists)*1.27 - (NEW.red_cards*3 + NEW.yellow_cards)*1.27), 2),
					ROUND(FLOOR(((NEW.goals*3 + NEW.assists)*1.27) - (NEW.red_cards*3 + NEW.yellow_cards)), 2))
		WHEN (NEW.goals*3 + NEW.assists)/NEW.minutes_played <= 0.053 THEN
			IF((NEW.red_cards*3 + NEW.yellow_cards)/NEW.minutes_played > 0.011, 
					ROUND(((NEW.goals*3 + NEW.assists) - (NEW.red_cards*3 + NEW.yellow_cards)*1.27), 2),
					ROUND(((NEW.goals*3 + NEW.assists) - (NEW.red_cards*3 + NEW.yellow_cards)), 2))
		END;
END$$

DELIMITER ;