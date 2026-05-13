USE football_db;

-- =========================================================
-- Benchmark 3 loai index de thay ro so dong quet truoc/sau
--
-- 1. Index 1 cot:    matches(match_date)
-- 2. Index nhieu cot: player_stats(season_id, goals)
-- 3. Full-text index: player(full_name)
--
-- Neu ban da tao index tu lan chay truoc, can drop index do truoc khi
-- chay phan TRUOC. MySQL khong ho tro DROP INDEX IF EXISTS truc tiep,
-- nen hay kiem tra bang SHOW INDEX roi drop thu cong neu can:
--
--   DROP INDEX idx_matches_match_date ON `matches`;
--   DROP INDEX idx_player_stats_season_goals ON `player_stats`;
--   DROP INDEX ft_player_full_name ON `player`;
--
-- Cach doc ket qua EXPLAIN ANALYZE:
--   - TRUOC: thuong thay Table scan hoac scan nhieu dong hon.
--   - SAU:   ky vong thay Index range scan / Full-text search.
--   - So sanh rows va actual time trong output.
-- =========================================================

SHOW INDEX FROM `matches`;
SHOW INDEX FROM `player_stats`;
SHOW INDEX FROM `player`;

-- =========================================================
-- A. INDEX 1 COT: matches(match_date)
-- Muc tieu:
--   Loc tran dau trong 1 thang. Truoc index se phai quet bang matches,
--   sau index chi range scan tren khoang ngay.
-- =========================================================

-- A1. TRUOC KHI THEM INDEX
EXPLAIN ANALYZE
SELECT
    match_id,
    match_date,
    season_id,
    home_team_id,
    away_team_id,
    home_score,
    away_score
FROM `matches`
WHERE match_date >= '2016-01-01'
  AND match_date <  '2016-02-01';

-- A2. THEM INDEX 1 COT
ALTER TABLE `matches`
ADD INDEX idx_matches_match_date (`match_date`);

ANALYZE TABLE `matches`;

-- A3. SAU KHI THEM INDEX
EXPLAIN ANALYZE
SELECT
    match_id,
    match_date,
    season_id,
    home_team_id,
    away_team_id,
    home_score,
    away_score
FROM `matches`
WHERE match_date >= '2016-01-01'
  AND match_date <  '2016-02-01';

-- =========================================================
-- B. INDEX NHIEU COT: player_stats(season_id, goals)
-- Muc tieu:
--   Loc cau thu ghi nhieu ban trong 1 mua. Truoc index, MySQL co the
--   dung fk_stats_season(season_id) roi quet tat ca cau thu cua mua do.
--   Sau index, MySQL range scan truc tiep tren (season_id, goals).
-- =========================================================

-- B0. Neu muon chon mua co du lieu ro hon, chay query nay truoc:
SELECT
    season_id,
    COUNT(*) AS total_players,
    MAX(goals) AS max_goals
FROM `player_stats`
GROUP BY season_id
ORDER BY total_players DESC
LIMIT 10;

-- B1. TRUOC KHI THEM INDEX
EXPLAIN ANALYZE
SELECT
    stat_id,
    player_id,
    season_id,
    goals,
    assists,
    minutes_played,
    rating
FROM `player_stats`
WHERE season_id = 48
  AND goals >= 15
ORDER BY goals DESC;

-- B2. THEM INDEX NHIEU COT
ALTER TABLE `player_stats`
ADD INDEX idx_player_stats_season_goals (`season_id`, `goals`);

ANALYZE TABLE `player_stats`;

-- B3. SAU KHI THEM INDEX
EXPLAIN ANALYZE
SELECT
    stat_id,
    player_id,
    season_id,
    goals,
    assists,
    minutes_played,
    rating
FROM `player_stats`
WHERE season_id = 48
  AND goals >= 15
ORDER BY goals DESC;

-- =========================================================
-- C. FULL-TEXT INDEX: player(full_name)
-- Muc tieu:
--   Tim cau thu theo tu khoa trong ten. Truoc full-text index, cach
--   pho bien la LIKE '%Ronaldo%' va buoc nay phai quet toan bang player.
--   Sau full-text index, dung MATCH ... AGAINST de tim bang inverted index.
--
-- Luu y:
--   MATCH ... AGAINST khong chay duoc truoc khi co FULLTEXT index, vi vay
--   phan TRUOC dung LIKE de tao baseline full table scan.
-- =========================================================

-- C1. TRUOC KHI THEM FULL-TEXT INDEX
EXPLAIN ANALYZE
SELECT
    player_id,
    full_name,
    position,
    birth_date,
    height,
    weight
FROM `player`
WHERE full_name LIKE '%Ronaldo%';

-- C2. THEM FULL-TEXT INDEX
ALTER TABLE `player`
ADD FULLTEXT INDEX ft_player_full_name (`full_name`);

ANALYZE TABLE `player`;

-- C3. SAU KHI THEM FULL-TEXT INDEX
EXPLAIN ANALYZE
SELECT
    player_id,
    full_name,
    position,
    birth_date,
    height,
    weight
FROM `player`
WHERE MATCH(full_name) AGAINST('+Ronaldo' IN BOOLEAN MODE);
