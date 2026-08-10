#

## Bài 3:
Nginx Reverse Proxy (định tuyến /web1, /web2).

### Mục tiêu:

- Kiến trúc:
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

- Chỉ truy cập được:

```bash
http://localhost:9000/web1
http://localhost:9000/web2
```
Và không truy cập trực tiếp được Web1, Web2.

- Tạo thêm Containter Nginx cùng lớp mạng/network với web1, web2

### Thực hiện:

- Kiến trúc thư mục
```bash
docker-learing/
└── Bai_03/
    └── nginx.conf

- Tạo file `nginx.config`
(nội dung file trong Bai_03\nginx.conf)

- Tạo container Ngix

```bash
docker run -d \
  --name nginx \
  --network web-network \
  -p 9000:9000 \
  -v "D:\\vck\\HocHanh\\01.Udemy\\01.docker\\00.Python_Project\\Bai_03\\nginx.conf:/etc/nginx/nginx.conf:ro" \
  nginx
```

- Kiểm tra

```bash
# nginx có nằm trong `web-network`
docker network inspect web-network

# truy cập vào container nginx xem nội dung file `nginx.conf`
docker exec -it nginx bash
cat /etc/nginx/nginx.conf

# kiểm tra trong nginx dùng trong hay ngoài container
docker inspect nginx | grep -A 15 "Mounts"
```

- Test

```bash
http://localhost:9000/web1
http://localhost:9000/web2
```

> - Note: Nếu muốn khi vào http://localhost:9000/ hiện trang chủ, chỉ cần thêm vao file nginx.conf:

```bash
location / {
    return 200 "Welcome to Nginx Reverse Proxy";
}
```

hoặc redirect:
```bash
location = / {
    return 302 /web1/;
}
```

