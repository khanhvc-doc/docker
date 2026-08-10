#

## Bài 01:

#### app.py
Nội dung trang web

#### requirements.txt
Chứa nhưng thư viện cần cài đặt

#### Dockerfile

- **Lớp 1**: "Mini OS" (python:3.12)
```bash
FROM python:3.12
```
Kiểm tra trên docker local có python bản này chưa, nếu chưa có lên docker hub tải về

- **Lớp 2**: Tạo thư mục /app
```bash
WORKDIR /app
```
Tạo thự mục làm việc `/app`  bên trong container, tất cả các lệnh sau sẽ thực hiện tại thư mục này

- **Lớp 3**: Bỏ file requirements.txt vào

```bash
COPY requirements.txt .
```
Copy file `requirements.txt` vào thư mục /app

- **Lớp 4**: Cài đặt thư viện (chạy pip install)

```bash
RUN pip install --no-cache-dir -r requirements.txt
```
Cài đặt các thư viện được liệt kê trong file `requirements.txt` trong container, `--no-cache-dir` yêu cầu pip không lưu lại bộ nhớ đệm (cache) khi tải gói về, nhằm giảm dụng lượng của Image sau này


- **Lớp 5**: Bỏ toàn bộ code còn lại vào

```bash
COPY . .
```
Sao chép toàn bộ các tệp và thư mục còn lại từ thư mục `hiện tại trên máy tính` `(dấu . đầu tiên)` vào `thư mục làm việc` bên trong container (dấu . thứ hai, tức là` /app`).

```bash
CMD ["python","app.py"]
```
Khi khởi động container thì chạy file `app.py` bằng ngôn ngữ python


#### Xem các layer
```bash
docker history <tên_image_hoặc_id>
```

#### Build Image

```bash
docker build -t web1 .
```
**Ý nghĩa**
Tạo (build) một Docker Image từ thư mục hiện tại.
- `docker build`: Lệnh cơ bản để bảo Docker đóng gói ứng dụng thành một Image.
- `-t (tag)`: Tham số dùng để đặt tên (và nhãn) cho Image giúp bạn dễ quản lý.
- `web1`: Tên do bạn tự đặt cho Docker Image này.
- `. (dấu chấm)`: Chỉ định Context (ngữ cảnh) build là thư mục hiện tại.

**Cách thức hoạt động**
- Docker quét thư mục hiện tại để **tìm file** `Dockerfile`.
- Docker đọc các chỉ thị trong Dockerfile (như cài đặt môi trường, copy code...)
- Docker tiến hành tạo ra một Image hoàn chỉnh mang tên `web1`.

#### Chạy Container từ Image
```bash
docker run -d \ 
--name web1 \
-p 9001:9001 \
web1:latest 
```
> - -d: Viết tắt của --detach, chạy ngầm
> - --name web1: Đặt tên cho container này là web1. có thể đặt tên khác
> - -p 9001:9001: `<port máy local>:<port container>`
> - web1:latest: là tên của `Docker Image`
> - **Hay**: Hãy chạy ngầm `-d` một container có tên `--name` là web1, được tạo ra từ image ``web1``. Đồng thời, mở cổng `9001 trên máy chủ` để kết nối trực tiếp với cổng `9001 bên trong container`.
