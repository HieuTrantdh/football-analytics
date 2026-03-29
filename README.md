# European Football Analytics System

## 📁 Project Structure

```bash
football-analytics/
├── sql/
│   ├── 01_schema_ddl.sql
│   ├── 02_triggers.sql
│   ├── 03_stored_procedures.sql
│   ├── 04_views.sql
│   ├── 05_indexes.sql
│   └── 06_complex_queries.sql
├── python/
│   ├── convert_sqlite_mysql.py
│   ├── db_connection.py
│   └── data_validation.py
├── notebooks/
│   ├── NB01_tong_quan.ipynb
│   ├── NB02_phan_tich_cau_thu.ipynb
│   └── NB03_phan_tich_giai_dau.ipynb
├── streamlit/
│   ├── app.py
│   ├── pages/
│   │   ├── 1_bang_xep_hang.py
│   │   ├── 2_cau_thu.py
│   │   └── 3_so_sanh_doi.py
│   └── utils/
│       └── db_utils.py
├── docs/
│   ├── ERD.png
│   ├── benchmark_report.pdf
│   └── bao_cao_ky_thuat.docx
├── CLAUDE_CONTEXT.md
├── TEAM_RULES.md
└── README.md
```

## 🧩 Mô tả cấu trúc

* **`sql/`**
  Chứa toàn bộ câu lệnh SQL phục vụ hệ thống:

  * Thiết kế schema (DDL)
  * Triggers tự động cập nhật dữ liệu (ví dụ: bảng xếp hạng)
  * Stored Procedures có tham số
  * Views phục vụ truy vấn thực tế
  * Indexes để tối ưu hiệu năng
  * Các truy vấn nâng cao (CTE, Window Functions)

* **`python/`**
  Các script xử lý dữ liệu và kết nối database:

  * Chuyển đổi dữ liệu từ SQLite sang MySQL
  * Thiết lập kết nối database
  * Kiểm tra và validate dữ liệu

* **`notebooks/`**
  Jupyter Notebook phục vụ phân tích dữ liệu:

  * Tổng quan dataset
  * Phân tích cầu thủ
  * Phân tích giải đấu
    → Bao gồm biểu đồ và insight

* **`streamlit/`**
  Ứng dụng web sử dụng Streamlit:

  * `app.py`: file chính chạy ứng dụng
  * `pages/`: các trang chức năng (bảng xếp hạng, cầu thủ, so sánh đội)
  * `utils/`: các hàm hỗ trợ kết nối và truy vấn database

* **`docs/`**
  Tài liệu của dự án:

  * ERD (sơ đồ quan hệ)
  * Báo cáo benchmark (trước/sau khi tối ưu index)
  * Báo cáo kỹ thuật tổng thể

* **`CLAUDE_CONTEXT.md`**
  File hỗ trợ bối cảnh và định hướng phát triển (dùng trong quá trình làm project)

* **`TEAM_RULES.md`**
  Quy tắc làm việc nhóm, phân công và quy trình phát triển

* **`README.md`**
  File giới thiệu tổng quan dự án và hướng dẫn sử dụng
