USE football_db;
-- =========================================================
-- FILE: Benchmark.sql
-- Mục đích: 
--   Phân tích và tối ưu hóa hiệu năng truy vấn (Query Performance)
--   cho bảng 'matches' trong hệ thống football_db.
-- Bao gồm:
--   1. Dọn dẹp - đảm bảo chưa có index nào trước khi đo.
--   2. Đo lường khi chưa có index.
--   3. Thêm index.
--   4. Đo lường sau khi thêm index.
-- =========================================================


-- =========================================================
-- PHẦN 1: Dọn dẹp - đảm bảo chưa có index nào trước khi đo.
-- Mục đích: Xóa các Index tự tạo để đưa bảng về trạng thái nguyên thủy.
-- Lưu ý: Không xóa các Index mặc định của Khóa ngoại (Foreign Key).
-- =========================================================
ALTER TABLE matches DROP INDEX idx_matches_match_date;
ALTER TABLE matches DROP INDEX idx_status_home_team;
ALTER TABLE matches DROP INDEX idx_matches_season_id;
ALTER TABLE matches DROP INDEX idx_matches_home_team;


-- =========================================================
-- PHẦN 2: Đo lường khi chưa có index.
-- Mục đích: 
--   Ghi nhận thông số thực thi gốc của MySQL khi phải quét toàn bảng.
-- =========================================================

-- [Query 1]: Tìm trận đấu theo ngày cụ thể
-- Đặc điểm: MySQL phải quét toàn bộ ~26,000 dòng (Table Scan).
EXPLAIN FORMAT=TRADITIONAL SELECT * FROM matches WHERE match_date = '2015-12-20';

-- [Query 2]: Lấy trận đấu của các mùa giải gần đây (Dùng JOIN)
-- Đặc điểm: Kiểm tra hiệu năng khi xử lý dải giá trị season_id và truy xuất dữ liệu tỷ số.
EXPLAIN FORMAT=TRADITIONAL
SELECT m.match_id, m.match_date, m.home_score, m.away_score
FROM matches m
JOIN team t1 ON m.home_team_id = t1.team_id
JOIN team t2 ON m.away_team_id = t2.team_id
WHERE m.season_id IN (8, 9, 10, 11);

-- [Query 3]: Thống kê Standings (Dùng GROUP BY)
-- Đặc điểm: Kiểm tra việc lọc trạng thái 'finished' và gom nhóm dữ liệu lớn.
EXPLAIN FORMAT=TRADITIONAL
SELECT home_team_id, COUNT(*) AS so_tran, SUM(home_score) AS tong_ban_thang
FROM matches WHERE status = 'finished' GROUP BY home_team_id;


-- =========================================================
-- PHẦN 3: Thêm index.
-- Mục đích: 
--   Áp dụng các kỹ thuật chỉ mục nâng cao để tăng tốc truy vấn.
-- Kỹ thuật:
--   - Index đơn cho ngày tháng.
--   - Composite Index cho thống kê (status, team).
--   - Covering Index cho JOIN (chứa đủ các cột SELECT).
-- =========================================================


ALTER TABLE matches ADD INDEX idx_matches_match_date (match_date);
ALTER TABLE matches ADD INDEX idx_status_home_team (status, home_team_id, home_score);
ALTER TABLE matches ADD INDEX idx_season_full (season_id, home_team_id, away_team_id, home_score, away_score);

-- =========================================================
-- PHẦN 4: Đo lường sau khi thêm index
-- Mục đích: 
--   Chứng minh hiệu quả tối ưu hóa qua các chỉ số EXPLAIN (Type, Rows, Extra).
-- =========================================================

-- [Query 1]: Sau tối ưu
-- Kỳ vọng: Chuyển sang Index Lookup, giảm Rows phải quét xuống mức tối thiểu.
EXPLAIN FORMAT=TRADITIONAL SELECT * FROM matches WHERE match_date = '2015-12-20';

-- [Query 2]: Sau tối ưu (Áp dụng Covering Index)
-- Kỳ vọng: Xuất hiện "Using index" trong cột Extra, không cần truy xuất vào Data file.
EXPLAIN FORMAT=TRADITIONAL
SELECT m.match_id, m.match_date, m.home_score, m.away_score
FROM matches m
JOIN team t1 ON m.home_team_id = t1.team_id
JOIN team t2 ON m.away_team_id = t2.team_id
WHERE m.season_id IN (8, 9, 10, 11);

-- [Query 3]: Sau tối ưu (Áp dụng Composite Index)
-- Kỳ vọng: Tận dụng thứ tự sắp xếp trên Index để tránh bảng tạm (Temporary table).
EXPLAIN FORMAT=TRADITIONAL
SELECT home_team_id, COUNT(*) AS so_tran, SUM(home_score) AS tong_ban_thang
FROM matches WHERE status = 'finished' 
GROUP BY home_team_id;