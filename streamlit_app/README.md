** Streamlit_App **

Thư mục này chứa ứng dụng Streamlit cho dự án Phân Tích Bóng Đá. Ứng dụng cung cấp giao diện tương tác để khám phá dữ liệu bóng đá, bao gồm bảng xếp hạng, so sánh đối đầu, cầu thủ xuất sắc, lịch sử đội bóng và tổng quan.

# Yêu cầu

Trước khi chạy ứng dụng Streamlit, hãy đảm bảo bạn đã cài đặt các thành phần sau:

- Python 3.8 hoặc cao hơn
- Thư viện Streamlit
- Các thư viện cần thiết (được liệt kê trong `requirements.txt` hoặc `pyproject.toml`)

# Thiết lập môi trường

1. **Cài đặt thư viện**:
   Di chuyển đến thư mục gốc của dự án và cài đặt các thư viện cần thiết:
   ```bash
   pip install -r requirements.txt
   ```

2. **Kết nối cơ sở dữ liệu**:
   Đảm bảo cơ sở dữ liệu đã được thiết lập và có thể truy cập. Ứng dụng sử dụng kết nối cơ sở dữ liệu được định nghĩa trong `.env`. Cập nhật thông tin đăng nhập cơ sở dữ liệu trong `.env` nếu cần.

# Chạy ứng dụng

1. Di chuyển đến thư mục `streamlit_app`:
   ```bash
   cd streamlit_app
   ```

2. Chạy ứng dụng Streamlit:
   ```bash
   streamlit run app.py
   ```

3. Mở ứng dụng trong trình duyệt. Theo mặc định, ứng dụng sẽ khả dụng tại:
   ```
   http://localhost:8501
   ```

# Cấu trúc thư mục

- `app.py`: Điểm khởi đầu chính của ứng dụng Streamlit.
- `db.py`: Xử lý kết nối cơ sở dữ liệu.
- `pages/`: Chứa các trang riêng lẻ của ứng dụng, như bảng xếp hạng, so sánh đối đầu, và nhiều hơn nữa.

# Xử lý sự cố

- Nếu ứng dụng không thể kết nối cơ sở dữ liệu, hãy kiểm tra thông tin đăng nhập trong `.env` và đảm bảo máy chủ cơ sở dữ liệu đang chạy.
- Nếu thiếu thư viện, hãy chạy lại lệnh cài đặt:
  ```bash
  pip install -r requirements.txt
  ```
