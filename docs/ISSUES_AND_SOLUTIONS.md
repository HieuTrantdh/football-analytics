\# ISSUES \& SOLUTIONS — DỰ ÁN PHÂN TÍCH BÓNG ĐÁ CHÂU ÂU



> Tổng hợp các vấn đề đã gặp và cách giải quyết

> Cập nhật liên tục trong suốt dự án

> Người tổng hợp: TV1



\---



\## TUẦN 1 — Setup \& Import Data



\---



\### \[ISS-01] Error 3823 — CHECK constraint không dùng được trên cột có FK



\*\*Gặp lúc:\*\* Tạo bảng `Match`, thêm constraint `CHECK(home\_team\_id <> away\_team\_id)`



\*\*Lỗi:\*\*



\*\*Nguyên nhân:\*\*

MySQL không cho phép dùng cùng 1 cột vừa trong FOREIGN KEY vừa trong CHECK constraint.



\*\*Cách giải quyết:\*\*

Bỏ CHECK constraint, thay bằng BEFORE INSERT trigger:

```sql

DELIMITER $$

CREATE TRIGGER before\_match\_insert

BEFORE INSERT ON `match`

FOR EACH ROW

BEGIN

&#x20;   IF NEW.home\_team\_id = NEW.away\_team\_id THEN

&#x20;       SIGNAL SQLSTATE '45000'

&#x20;       SET MESSAGE\_TEXT = 'home\_team\_id và away\_team\_id không được trùng nhau';

&#x20;   END IF;

END$$

DELIMITER ;

```



\*\*Bài học:\*\* Với MySQL, mọi ràng buộc liên quan đến cột có FK nên dùng trigger thay vì CHECK.



\---



\### \[ISS-02] Schema nhóm thiết kế khác hoàn toàn với dataset gốc Kaggle



\*\*Gặp lúc:\*\* Bắt đầu viết script import data



\*\*Vấn đề:\*\*

Dataset gốc có 7 bảng tên khác, cột khác, không có FK:



| Dataset gốc | Schema nhóm |

|-------------|-------------|

| `Country` | Gộp vào `league.country` |

| `League` (3 cột) | `league` (4 cột, thêm `tier`) |

| `Match` (115 cột) | `match` (8 cột) |

| `Player` (7 cột) | `player` (7 cột, đổi tên) |

| `Player\_Attributes` (42 cột) | `player\_stats` (9 cột) |

| `Team` (5 cột) | `team` (6 cột) |

| `Team\_Attributes` (25 cột) | Không dùng |

| Không có | `season` (tự tạo từ Match) |

| Không có | `standings` (tự tạo, trigger cập nhật) |



\*\*Cách giải quyết:\*\*

Viết script migration riêng `sql/02\_migrate\_data.sql` — dùng `INSERT INTO ... SELECT FROM` để mapping dữ liệu từ bảng gốc sang bảng chuẩn, có xử lý đổi tên cột và bỏ cột không cần.



\*\*Bài học:\*\* Luôn phân tích kỹ cấu trúc dataset gốc trước khi thiết kế schema — tránh thiết kế xong mới phát hiện data không khớp.



\---



\### \[ISS-03] Không INSERT được cross-database (2 database khác nhau)



\*\*Gặp lúc:\*\* Chạy script migration từ database `football\_raw` sang `football\_db`



\*\*Lỗi:\*\*



\*\*Nguyên nhân:\*\*

Script dùng tên bảng trực tiếp không có tên database phía trước — MySQL không biết bảng thuộc database nào.



\*\*Cách giải quyết:\*\*

Thêm tên database trước tên bảng theo cú pháp `database\_name.table\_name`:

```sql

\-- Sai

INSERT INTO league SELECT \* FROM league\_clean;



\-- Đúng

INSERT INTO football\_db.league

SELECT \* FROM football\_raw.league\_clean;

```



\*\*Bài học:\*\* Khi làm việc với nhiều database cùng lúc, luôn viết đầy đủ `database.table` để tránh nhầm lẫn.



\---



\### \[ISS-04] Error 3819 — CHECK constraint bị vi phạm khi insert rating



\*\*Gặp lúc:\*\* Bước 6 script migration — INSERT vào `player\_stats`



\*\*Lỗi:\*\*

\*\*Nguyên nhân:\*\*

Constraint ban đầu đặt `rating BETWEEN 0 AND 10` nhưng dataset FIFA dùng thang điểm 0–100 (VD: Messi = 94, Ronaldo = 93).



\*\*Cách giải quyết:\*\*

Sửa lại constraint cho đúng thực tế:

```sql

\-- Bỏ constraint cũ

ALTER TABLE football\_db.player\_stats

DROP CONSTRAINT ck\_stats\_rating;



\-- Thêm constraint mới đúng thang điểm FIFA

ALTER TABLE football\_db.player\_stats

ADD CONSTRAINT ck\_stats\_rating

CHECK (rating IS NULL OR rating BETWEEN 0.00 AND 100.00);

```



\*\*Bài học:\*\* Trước khi đặt CHECK constraint, kiểm tra MIN/MAX thực tế của data:

```sql

SELECT MIN(overall\_rating), MAX(overall\_rating)

FROM football\_raw.player\_attributes\_clean;

```



\---



\### \[ISS-05] Error 1062 — Duplicate entry vi phạm UNIQUE(player\_id, season\_id)



\*\*Gặp lúc:\*\* Bước 6 script migration — INSERT vào `player\_stats`



\*\*Lỗi:\*\*

\*\*Nguyên nhân:\*\*

`player\_attributes\_clean` lưu nhiều lần đánh giá cho cùng 1 cầu thủ trong cùng 1 mùa (FIFA cập nhật rating theo tuần). Khi GROUP BY không đủ chặt sẽ tạo ra duplicate.



\*\*Cách giải quyết:\*\*

Dùng subquery lấy đúng 1 bản ghi mới nhất cho mỗi cặp `(player\_api\_id, năm)` trước khi INSERT:

```sql

\-- Lọc chỉ lấy đánh giá mới nhất mỗi cầu thủ mỗi năm

SELECT pac.player\_api\_id, pac.overall\_rating

FROM player\_attributes\_clean pac

INNER JOIN (

&#x20;   SELECT player\_api\_id, YEAR(date) AS yr, MAX(date) AS latest\_date

&#x20;   FROM player\_attributes\_clean

&#x20;   WHERE overall\_rating IS NOT NULL

&#x20;   GROUP BY player\_api\_id, YEAR(date)

) latest

&#x20;   ON pac.player\_api\_id = latest.player\_api\_id

&#x20;   AND pac.date         = latest.latest\_date

```



Hoặc dùng `INSERT IGNORE` để tự bỏ qua duplicate:

```sql

INSERT IGNORE INTO player\_stats (...) SELECT ...;

```



\*\*Bài học:\*\* Khi import data từ nguồn có thể có duplicate, luôn kiểm tra trước bằng `GROUP BY ... HAVING COUNT(\*) > 1` và dùng `INSERT IGNORE` hoặc `ON DUPLICATE KEY UPDATE` để an toàn.



\---



\### \[ISS-06] Một số cột có data null hoặc = 0 sau khi import



\*\*Gặp lúc:\*\* Verify data sau khi migration hoàn tất



\*\*Vấn đề:\*\*

Các cột sau không có data thực tế từ dataset gốc:



| Bảng | Cột | Lý do |

|------|-----|-------|

| `player` | `position` | Dataset gốc không có position rõ ràng → gán tạm 'MID' |

| `player` | `nationality`, `market\_value` | Không có trong dataset gốc |

| `player` | `team\_id` | Mapping cầu thủ → đội phức tạp → gán tạm = 1 |

| `team` | `city`, `stadium`, `capacity` | Không có trong dataset gốc |

| `player\_stats` | `goals`, `assists` | Không có trong dataset gốc |

| `player\_stats` | `yellow\_cards`, `red\_cards` | Lưu dạng XML trong `match\_clean.card` — chưa parse |

| `player\_stats` | `minutes\_played` | Không có trong dataset gốc |



\*\*Ảnh hưởng đến tuần 2:\*\*

\- Trigger, Views, Stored Procedures liên quan đến kết quả trận đấu → \*\*không bị ảnh hưởng\*\*

\- Query/phân tích liên quan đến goals, assists, cards → \*\*tránh dùng, kết quả vô nghĩa\*\*

\- Benchmark indexing → \*\*không bị ảnh hưởng\*\*



\*\*Cách xử lý trong báo cáo:\*\*

Ghi chú rõ trong báo cáo: \*"Dataset gốc không cung cấp thống kê cá nhân cầu thủ theo dạng số trực tiếp. Các cột goals, assists, cards được giữ mặc định = 0 do dữ liệu gốc lưu dưới dạng XML chưa được chuẩn hóa."\*



\---



\## TUẦN 2 — Triggers, Stored Procedures, Views, Indexing



> Cập nhật tiếp khi phát sinh vấn đề mới...



\---



\## GHI CHÚ CHUNG



\- Mỗi khi gặp lỗi mới → TV1 thêm vào file này ngay

\- Format: \[ISS-XX] Tên lỗi ngắn gọn → Nguyên nhân → Cách fix → Bài học

\- File này dùng trong báo cáo kỹ thuật cuối kỳ phần "Các vấn đề gặp phải"



