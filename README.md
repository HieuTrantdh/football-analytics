# European Football Analytics System

## Cấu trúc dự án

```bash
football-analytics/
├── sql/
│   ├── Benchmark.sql
│   ├── Complex queries.sql
│   ├── Stored procedure.sql
│   ├── Trigger.sql
│   ├── View.sql
├── python/
│   ├── convert_sqlite_mysql.py
│   ├── db_connection.py
│   └── data_validation.py
├── notebooks/
│   ├── NB01_
│   ├── Phân tích bảng xếp hạng, trận đấu.ipynb
├── streamlit_app/
│   ├── app.py
│   ├── db.py
│   ├── pages/
│   │   ├── 1_standings.py
│   │   ├── 2_head_to_head.py
│   │   ├── 3_top_players.py
│   │   ├── 4_team_history.py
│   │   └── 5_overview.py
├── docs/
│   ├── ISSUES_AND_SOLUTIONS.md
├── pyproject.toml
├── LICENSE
└── README.md
```

## Mô tả chi tiết

### **`sql/`**
Chứa các tệp SQL phục vụ cho cơ sở dữ liệu:
- **Benchmark.sql**: Các truy vấn kiểm tra hiệu năng.
- **Complex queries.sql**: Các truy vấn phức tạp.
- **Stored procedure.sql**: Các thủ tục lưu trữ.
- **Trigger.sql**: Các trigger tự động cập nhật dữ liệu.
- **View.sql**: Các view hỗ trợ truy vấn.

### **`python/`**
Chứa các script Python:
- **convert_sqlite_mysql.py**: Chuyển đổi dữ liệu từ SQLite sang MySQL.
- **db_connection.py**: Thiết lập kết nối cơ sở dữ liệu.
- **data_validation.py**: Kiểm tra và xác thực dữ liệu.

### **`notebooks/`**
Chứa các Jupyter Notebook phục vụ phân tích dữ liệu:
- **NB01_**: Notebook tổng quan.
- **Phân tích bảng xếp hạng, trận đấu.ipynb**: Phân tích chi tiết bảng xếp hạng và trận đấu.

### **`streamlit_app/`**
Ứng dụng web sử dụng Streamlit:
- **app.py**: File chính chạy ứng dụng.
- **db.py**: Xử lý kết nối cơ sở dữ liệu.
- **pages/**: Chứa các trang chức năng:
  - **1_standings.py**: Trang bảng xếp hạng.
  - **2_head_to_head.py**: Trang so sánh đối đầu.
  - **3_top_players.py**: Trang cầu thủ xuất sắc.
  - **4_team_history.py**: Trang lịch sử đội bóng.
  - **5_overview.py**: Trang tổng quan.

### **`docs/`**
Chứa tài liệu dự án:
- **ISSUES_AND_SOLUTIONS.md**: Các vấn đề và giải pháp.

### **Các tệp khác**
- **pyproject.toml**: Tệp cấu hình dự án.
- **LICENSE**: Thông tin bản quyền.
- **README.md**: Tệp giới thiệu tổng quan dự án.
