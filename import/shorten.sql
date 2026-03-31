create database soccer_db_clean;
use soccer_db_clean;
-- 1. Bảng Country (Bảng độc lập nhất)
CREATE TABLE Country_Clean (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- 2. Bảng League (Phụ thuộc Country)
CREATE TABLE League_Clean (
    league_id INT PRIMARY KEY,
    country_id INT,
    name VARCHAR(255),
    FOREIGN KEY (country_id) REFERENCES Country_Clean(id)
);

-- 3. Bảng Team (Bảng độc lập - Bỏ id vô nghĩa)
CREATE TABLE Team_Clean (
    team_api_id INT PRIMARY KEY,
    team_fifa_api_id INT,
    team_long_name VARCHAR(255),
    team_short_name VARCHAR(50)
);

-- 4. Bảng Player (Bảng độc lập - Bỏ id vô nghĩa)
CREATE TABLE Player_Clean (
    player_api_id INT PRIMARY KEY,
    player_name VARCHAR(255),
    player_fifa_api_id INT,
    birthday DATE,
    height FLOAT,
    weight INT
);

-- 5. Bảng Match (Bảng trung tâm - Bỏ id thứ tự)
-- Quả date chỉ có ngày nên mình set luôn là kiểu DATE cho nhẹ DB
CREATE TABLE Match_Clean (
    match_api_id INT PRIMARY KEY,
    country_id INT,
    league_id INT,
    season VARCHAR(20),
    stage INT,
    date DATE, 
    home_team_api_id INT,
    away_team_api_id INT,
    home_team_goal INT,
    away_team_goal INT,
    goal text,
    foulcommit text,
    card text,
    corner text,
    possession text,
    FOREIGN KEY (country_id) REFERENCES Country_Clean(id),
    FOREIGN KEY (league_id) REFERENCES League_Clean(league_id),
    FOREIGN KEY (home_team_api_id) REFERENCES Team_Clean(team_api_id),
    FOREIGN KEY (away_team_api_id) REFERENCES Team_Clean(team_api_id)
);

-- 6. Bảng Team_Attributes (Phụ thuộc Team)
CREATE TABLE Team_Attributes_Clean (
    id INT PRIMARY KEY AUTO_INCREMENT,
    team_api_id INT,
    team_fifa_api_id INT,
    date DATE,
    buildUpPlaySpeedClass VARCHAR(50),
    buildUpPlayPassingClass VARCHAR(50),
    buildUpPlayDribblingClass VARCHAR(50),
    chanceCreationPassingClass VARCHAR(50),
    chanceCreationCrossingClass VARCHAR(50),
    chanceCreationShootingClass VARCHAR(50),
    defencePressureClass VARCHAR(50),
    defenceAggressionClass VARCHAR(50),
    FOREIGN KEY (team_api_id) REFERENCES Team_Clean(team_api_id)
);

-- 7. Bảng Player_Attributes (Phụ thuộc Player)
CREATE TABLE Player_Attributes_Clean (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_api_id INT,
    player_fifa_api_id INT,
    date DATE,
    overall_rating INT,
    potential INT,
    prefered_foot VARCHAR(20),
    attacking_work_rate VARCHAR(20),
    defensive_work_rate VARCHAR(20),
    finishing INT,
    sprint_speed INT,
    balance INT,
    stamina INT,
    strength INT,
    penalties INT,
    FOREIGN KEY (player_api_id) REFERENCES Player_Clean(player_api_id)
);

-- 1. Bơm dữ liệu bảng Country
INSERT INTO soccer_db_clean.Country_Clean (id, name)
SELECT id, name FROM soccer_db.country;

-- 2. Bơm dữ liệu bảng League 
-- (Lấy luôn country_id đắp vào league_id như phân tích ban đầu)
INSERT INTO soccer_db_clean.League_Clean (league_id, country_id, name)
SELECT id, country_id, name FROM soccer_db.League;

-- 3. Bơm dữ liệu bảng Team 
-- (Bỏ qua cột id tự tăng vô nghĩa của DB cũ)
INSERT INTO soccer_db_clean.Team_Clean (team_api_id, team_fifa_api_id, team_long_name, team_short_name)
SELECT team_api_id, team_fifa_api_id, team_long_name, team_short_name FROM soccer_db.Team;

-- 4. Bơm dữ liệu bảng Player
INSERT INTO soccer_db_clean.Player_Clean (player_api_id, player_name, player_fifa_api_id, birthday, height, weight)
SELECT player_api_id, player_name, player_fifa_api_id, birthday, height, weight FROM soccer_db.Player;

-- 5. Bơm dữ liệu bảng Match (Bảng trung tâm)
INSERT INTO soccer_db_clean.Match_Clean (
    match_api_id, country_id, league_id, season, stage, 
    date, home_team_api_id, away_team_api_id, home_team_goal, away_team_goal, goal, foulcommit, card, corner, possession
)
SELECT 
    match_api_id, country_id, country_id, season, stage, -- league_id lấy từ country_id
    date, home_team_api_id, away_team_api_id, home_team_goal, away_team_goal, goal, foulcommit, card, corner, possession
FROM soccer_db.Match;

-- 6. Bơm dữ liệu bảng Team_Attributes
INSERT INTO soccer_db_clean.Team_Attributes_Clean (
    id, team_api_id, team_fifa_api_id, date, 
    buildUpPlaySpeedClass, buildUpPlayPassingClass, buildUpPlayDribblingClass, 
    chanceCreationPassingClass, chanceCreationCrossingClass, chanceCreationShootingClass, 
    defencePressureClass, defenceAggressionClass
)
SELECT 
    id, team_api_id, team_fifa_api_id, date, 
    buildUpPlaySpeedClass, buildUpPlayPassingClass, buildUpPlayDribblingClass, 
    chanceCreationPassingClass, chanceCreationCrossingClass, chanceCreationShootingClass, 
    defencePressureClass, defenceAggressionClass 
FROM soccer_db.Team_Attributes;

-- 7. Bơm dữ liệu bảng Player_Attributes
INSERT INTO soccer_db_clean.Player_Attributes_Clean (
    id, player_api_id, player_fifa_api_id, date, 
    overall_rating, potential, prefered_foot, attacking_work_rate, defensive_work_rate, 
    finishing, sprint_speed, balance, stamina, strength, penalties
)
SELECT 
    id, player_api_id, player_fifa_api_id, date, 
    overall_rating, potential, preferred_foot, attacking_work_rate, defensive_work_rate, 
    finishing, sprint_speed, balance, stamina, strength, penalties 
FROM soccer_db.playerstats;

select * from player_clean;

