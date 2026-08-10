# PHASE 1


## 1. Định nghĩa website/proxy nào cần chạy
### - File căn bản
- **pit.conf**
```bash
server {
    listen 80;
    server_name pit3.hansollvina.com;

    access_log /var/log/nginx/pit/access.log main;
    error_log  /var/log/nginx/pit/error.log;

    location / {
        proxy_pass http://192.168.99.32:4003;
        include /etc/nginx/snippets/proxy-common.conf;
    }
}
```
- **Ý Nghĩa**:
```bash
pit.conf
   │
   ├── domain nào?       pit3.hansollvina.com
   ├── listen port nào?  80
   ├── proxy đi đâu?     192.168.99.32:4003
   │
   └── include
         ↓
   proxy-common.conf
         ↓
   các thiết lập proxy dùng chung
```

> Chú ý: nếu nhiều host thì liệt vào mục server_name, các host cách nhau 1 khoảng trắng:
> - ví dụ: server_name pit3.hansollvina.com pit2.hansollvina.com;
### - File che dấu thông tin:

- **hr.conf**
```bash
server {
    listen 80;
    server_name hr3.hansollvina.com;

    access_log /var/log/nginx/pit/access.log main;
    error_log  /var/log/nginx/pit/error.log;

    location / {
        proxy_pass http://192.168.99.12:800/esys/;
        include /etc/nginx/snippets/proxy-common.conf;

        proxy_redirect /esys/ /; # cần che /esys/
    }
}
```
> - Thêm dòng: `proxy_redirect /`noi_dung_can_che`/ /;`

- **Kết quả mong muốn**:
```bash
                    PUBLIC
                      │
                      ▼
        http://hr3.hansollvina.com
                      │
                      ▼
                    NGINX
                      │
            che IP + port + path
                      │
                      ▼
        http://192.168.99.12:800/esys/
                    PRIVATE
```


## 2. Bộ cấu hình dùng chung cho các proxy.
- **Proxy-common.conf**
```bash
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

proxy_http_version 1.1;

proxy_connect_timeout 10s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
```
- **Ý nghĩa**:
    * Giả sử:

        ```bash
        PC User:       192.168.5.100
        Nginx:         192.168.99.10
        Backend:       192.168.99.32:4003
        Domain:        pit3.hansollvina.com
        User truy cập: http://pit3.hansollvina.com
        ```
    * Thì các giá trị thực tế gần như
        ```bash
        proxy_set_header Host $host;
        # $host = pit3.hansollvina.com

        proxy_set_header X-Real-IP $remote_addr;
        # $remote_addr = 192.168.5.100 (IP client)

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # thêm IP client vào chuỗi proxy

        proxy_set_header X-Forwarded-Proto $scheme;
        # $scheme = http hoặc https
        ```

## File cấu hình gốc/chính của Nginx
```bash
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    '"$http_x_forwarded_for"';

    sendfile on;
    keepalive_timeout 65;

    include /etc/nginx/conf.d/*.conf;
}
```
### Luồng hoạt động/liên quan

```bash
nginx.conf
   ↓
include /etc/nginx/conf.d/*.conf; # nạp/đọc tất cả file .conf. Ví dụ pit.conf
   ↓
pit.conf
   ↓
include /etc/nginx/snippets/proxy-common.conf;
   ↓
proxy-common.conf
```

## Test

```bash
curl -I -H "Host: pit3.hansollvina.com" http://localhost/
```

# PHASE 2





