USE football_db;
-- Benchmark trước khi thêm index
ALTER TABLE `match` DROP INDEX idx_matches_match_date;
EXPLAIN FORMAT=TRADITIONAL
SELECT SQL_NO_CACHE * FROM `match` WHERE match_date = '2015-12-20';
-- Thêm index
ALTER TABLE `match` ADD INDEX idx_matches_match_date (match_date);
-- Benchmark sau khi thêm index
EXPLAIN FORMAT=TRADITIONAL
SELECT SQL_NO_CACHE * FROM `match` WHERE match_date = '2015-12-20';




