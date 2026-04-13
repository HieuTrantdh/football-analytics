USE football_db;
-- Benchmark trước khi thêm index
ALTER TABLE matches DROP INDEX idx_matches_match_date;
EXPLAIN FORMAT=TRADITIONAL
SELECT SQL_NO_CACHE * FROM matches WHERE match_date = '2015-12-20';
-- Thêm index
ALTER TABLE matches ADD INDEX idx_matches_match_date (match_date);
-- Benchmark sau khi thêm index
EXPLAIN FORMAT=TRADITIONAL
SELECT SQL_NO_CACHE * FROM matches WHERE match_date = '2015-12-20';
