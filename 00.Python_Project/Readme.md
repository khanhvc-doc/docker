#

## Bài 1: 1 Flask app + 1 container (Image, Container, Port Mapping).
- Dùng port 9001
- Copy python từ docker hub, có tinh chỉnh bản gốc, thông tin cài đặt tùy thuộc vào file `Dockerfile`

## Bài 2: 2 Flask app + Docker Network (DNS nội bộ, giao tiếp giữa container).
- Tương tự bài 1 (nhưn dùng port 9002)
- Tạo thêm card cho container bài 1, 2.

## Bài 3: Nginx Reverse Proxy (định tuyến /web1, /web2).
- Dùng port 9000
- Tải Nginx bản mới nhất từ docker hub, **Bind Mount volume** về file cấu hình `nginx.conf` bên ngoài container
- Bên ngoài truy cập vào web1, web2
```bash
http://localhost:9000/web1
http://localhost:9000/web2
```
Kiến trúc
```bash
                   Windows Host
                       |
             http://localhost:9000
                       |
                  +------------+
                  |   Nginx    |
                  | Reverse    |
                  |   Proxy    |
                  +------------+
                        |
                    web-network
                        |
                ────────└────────
                  /            \
                 /              \
        localhost:9001     localhost:9002
        +-------------+    +-------------+
        | Flask Web1  |    | Flask Web2  |
        | Python 3.12 |    | Python 3.13 |
        +-------------+    +-------------+
```

## Bài 4: Docker Compose (quản lý toàn bộ stack bằng một file).
- Dùng port 9010, 9011, 9012
- Tương tự bài 1, 2, 3 nhưng chỉ 1 lệnh
- Bài 3 có tinh chỉnh tí, nginx.conf đưa thẳng vào container luôn

## Bài 5: Persist dữ liệu bằng Volume (dữ liệu nằm ngoài container).
- Dùng port 9050
- Named Volumed: nơi lưu trữ container tự quyết
- Bind Mount: Nơi lưu trên trên Windows

## Bài 6: Triển khai ứng dụng Web thực tế (Flask + PostgreSQL + Nginx)