CREATE DATABASE IF NOT EXISTS european_soccer;
USE european_soccer;
-- 1 
create table league (
  league_id Int primary key auto_increment , 
   `name` varchar(100)  not null unique ,
    country_id Int not null , 
    tier TinyInt default 1 
);
-- 2 
create table team (
  team_id int primary key auto_increment ,
  `name` varchar(100) not null , 
  city varchar(100)  , 
  stadium varchar(100) , 
  capacity Int 
);
-- 3 
create table season  (
  season_id int primary key auto_increment , 
  league_id int not null , 
  `year` varchar(10) not null , 
  start_date Date , 
  end_date Date 
);
-- 4 
create table player(
	player_id int primary Key auto_increment , 
    team_id Int , 
    full_name varchar(150) not null , 
    position varchar(10) , 
    birth_date Date , 
    nationality varchar(100) , 
    market_value Decimal(15,2)
) ; 

-- 5 

create table `match`  (
	match_id int primary key auto_increment , 
    season_id int not null , 
    home_team_id int  not null , 
    away_team_id int not null , 
    match_date date not null , 
    home_score TinyInt not null , 
    away_score TinyInt not null ,
    `status` varchar(20) default 'Completed'
);

-- 6 
create table standings (
	standing_id int primary key auto_increment ,
    team_id int not null , 
    season_id int not null , 
    wins int default 0 , 
    draws int default 0 , 
    losses int default 0 , 
    points int default 0 , 
    goals_for int default 0 , 
    goals_against int default 0 
);

-- 7 

create table player_stats (
	stat_id int primary key auto_increment , 
    player_id int not null , 
    season_id int not null , 
    goals Int Not null ,
    assists Int default 0 , 
    yellow_cards int default 0 , 
    red_cards int default 0 , 
    minutes_played int default 0 , 
    rating decimal(4,2) 
);
-- them o bang league 
Alter table league 
	add constraint league_name unique (name) ;  

-- them o bang season 
alter table season 
	ADD CONSTRAINT fk_season_league FOREIGN KEY (league_id) REFERENCES league(league_id) ;
-- them o bang team 
alter table team 
	add constraint team_name unique (name),
    add	constraint chk_team_capacity check(capacity >= 0 );

-- them o bang player 

alter table player 
	ADD CONSTRAINT fk_player_team FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE SET NULL,
    ADD CONSTRAINT chk_player_market_value CHECK (market_value >= 0); 
    
-- them o bang match 
alter table `match`
    Add constraint fk_match_season FOREIGN KEY (season_id) REFERENCES season(season_id),
    Add constraint fk_match_home FOREIGN KEY (home_team_id) REFERENCES team(team_id),
    Add constraint fk_match_away FOREIGN KEY (away_team_id) REFERENCES team(team_id),
    Add constraint chk_teams_diff CHECK (home_team_id != away_team_id);
    
-- them o bang player_stat 
alter table  player_stats 
			ADD CONSTRAINT fk_player_stats_player FOREIGN KEY (player_id) REFERENCES player(player_id),
			ADD CONSTRAINT fk_player_stats_season FOREIGN KEY (season_id) REFERENCES season(season_id),
			ADD CONSTRAINT uq_player_stats_player_season UNIQUE (player_id, season_id),
			ADD CONSTRAINT chk_player_stats CHECK (goals >= 0 AND assists >= 0 AND yellow_cards >= 0 AND red_cards >= 0 AND minutes_played >= 0),
			ADD CONSTRAINT chk_player_rating CHECK (rating >= 0 AND rating <= 10);

-- them o standings 
alter table standings 
	add constraint fk_standings_team FOREIGN KEY (team_id) REFERENCES team(team_id),
    Add constraint fk_standings_season FOREIGN KEY (season_id) REFERENCES season(season_id),
    ADD Constraint standings_team_season UNIQUE (team_id, season_id),
    ADD constraint CHECK (wins >= 0 AND draws >= 0 AND losses >= 0 AND points >= 0 AND goals_for >= 0 AND goals_against >= 0);
    