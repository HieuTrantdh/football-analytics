1. Do trong server nhom chua co stored procedure va views nen phai dung database local

**Bước 1:** Trong thư mục `streamlit`, tạo một file tên là `.env` (nhớ có dấu chấm ở đầu).
**Bước 2:** Copy nội dung sau dán vào file `.env` và sửa lại thông tin cho khớp với MySQL trên máy của bạn:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=ten_database_local_cua_ban
DB_USER=root
DB_PASS=mat_khau_mysql_cua_ban


2.  Cai dat streamlit

pip install -r requirements.txt  # Cài thư viện (nếu có file này)
python -m streamlit run app.py   # Chạy app


3. sua ten  stored procedure  GetTopPLayerBySeason sang GetTopPlayersBySeason
hoac sua trong cau_thu.py

-- 1. Xóa hàm cũ bị sai tên
DROP PROCEDURE IF EXISTS GetTopPLayerBySeason;
DROP PROCEDURE IF EXISTS GetTopPlayersBySeason;

-- 2. Tạo lại hàm chuẩn có chữ 's'
DELIMITER $$
CREATE PROCEDURE `GetTopPlayersBySeason`(
  in p_season_year varchar(20),
  in p_top_n int
)
begin
	select
		rank() over (order by ps.rating desc ) as `rank`,
        p.full_name,
        ps.goals,
        ps.assists,
		ps.yellow_cards,
		ps.red_cards,
		ps.minutes_played,
        ps.rating
        from player_stats ps
        join player p  on p.player_id = ps.player_id
        join season s on ps.season_id = s.season_id
        where s.`year` = p_season_year COLLATE utf8mb4_unicode_ci
        and ps.rating is not null
        order by ps.rating desc
        limit p_top_n;
end $$
DELIMITER ;
```
