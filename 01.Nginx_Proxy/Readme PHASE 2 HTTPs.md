#

## PHASE 2: HTTPs
- QUAN TRỌNG: Các host cần xin CA phải được tạo trên DNS (phân giải nslookup với 8.8.8.8 phải thành công)
- Cấu hình xin CA cho 1 domain trỏ về 1 host


### I. CẤU TRÚC

```bash
01.Nginx_Proxy/
├── docker-compose.yml
├── nginx.conf
├── conf.d/
│   ├── sims.conf
│   └── subcon.conf
├── snippets/
│   └── proxy-common.conf
├── logs/
│ 
│   # bổ sung
└── certbot/
    ├── www/       # → chứa file challenge
    └── conf/      # → chứa certificate thật
```

### II. THỰC HIỆN

#### A. Chuẩn bị

##### 1. Tạo thư mục
```bash
mkdir -p certbot/www
mkdir -p certbot/conf
```
##### 2. Bind mount cho Nginx

- Thêm mới:
```bash
    ports:
      - "443:443"

    volumes:
      - ./certbot/www:/var/www/certbot:ro
      - ./certbot/conf:/etc/letsencrypt:ro
```

    - File đầy đủ
    ```bash
    services:

  nginx:
    image: nginx:stable
    container_name: nginx-proxy

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./snippets:/etc/nginx/snippets:ro
      - ./logs:/var/log/nginx

        # thêm 2 dòng này
      - ./certbot/www:/var/www/certbot:ro
      - ./certbot/conf:/etc/letsencrypt:ro

    restart: unless-stopped
    ```

- Luồng challenge
```bash
Windows
certbot/www/
       ↓ bind mount
Container
/var/www/certbot/
```

##### 3. Thêm mới nội dung vào file .conf 
*(thêm vào sau các dòng ghi log, nếu với domain khác thì `bắt đầu từ chỗ này`)*
```bash
server {
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
```
- Ví dụ:
    - `pit.conf`
    ```bash
    server {
        listen 80;
        server_name pit3.hansollvina.com pit2.hansollvina.com;

        access_log /var/log/nginx/pit/access.log main;
        error_log  /var/log/nginx/pit/error.log;

        # thêm dòng này
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            proxy_pass http://192.168.99.32:4003;
            include /etc/nginx/snippets/proxy-common.conf;
        }
    }
    ```

##### 4. Recreate container

```bash
docker compose down
docker compose config
docker compose up -d

# test
docker compose ps
docker exec nginx-proxy-v2 nginx -t
```

##### 5. Test ACME challenge thủ công

```bash
mkdir -p certbot/www/.well-known/acme-challenge
echo "LET-S-ENCRYPT-TEST" > certbot/www/.well-known/acme-challenge/test.txt

curl \
-H "Host: subcon3.hansollvina.com" \
http://localhost/.well-known/acme-challenge/test.txt


curl \
-H "Host: pit3.hansollvina.com" \
http://localhost/.well-known/acme-challenge/test.txt


```

#### B. Xin certificate thật bằng Certbot

##### 1. Xin certificate cho XX domain
*(docker run --rm ): Khởi chạy một container Docker và tự động `xóa container này sau khi lệnh hoàn tất` để giải phóng dung lượng*

- Windows
```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy\certbot\www:/var/www/certbot" \
  -v "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy\certbot\conf:/etc/letsencrypt" \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --non-interactive \
  --agree-tos \
  --email khanhvc3@hansollvina.com \
  -d pit3.hansollvina.com

```

hoặc không cần email, nhieu domain

```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy\certbot\www:/var/www/certbot" \
  -v "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy\certbot\conf:/etc/letsencrypt" \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --non-interactive \
  --agree-tos \
  --register-unsafely-without-email \
 
  -d sims3.hansollvina.com \
  -d subcon.hansollvina.com \
  -d subcon3.hansollvina.com
```

- Ubuntu
```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "$(pwd)/certbot/www:/var/www/certbot" \
  -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --non-interactive \
  --agree-tos \
  --register-unsafely-without-email \
  -d pit3.hansollvina.com
```

##### 2. Sửa file .conf

- File `pit.conf`
```bash
server {
    listen 80;
    server_name pit3.hansollvina.com pit2.hansollvina.com;

    access_log /var/log/nginx/pit/access.log main;
    error_log  /var/log/nginx/pit/error.log;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://192.168.99.32:4003;
        include /etc/nginx/snippets/proxy-common.conf;
    }
}

server {
    listen 443 ssl;
    server_name pit3.hansollvina.com;

    ssl_certificate     /etc/letsencrypt/live/pit3.hansollvina.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pit3.hansollvina.com/privkey.pem;

    access_log /var/log/nginx/pit/ssl_access.log main;
    error_log  /var/log/nginx/pit/ssl_error.log;

    location / {
        proxy_pass http://192.168.99.32:4003;
        include /etc/nginx/snippets/proxy-common.conf;
    }
}
```
##### 3. TEST

```bash
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# test
docker exec nginx-proxy nginx -T 2>&1 | grep -A 20 "listen 443 ssl"

#
curl -Ik \
-H "Host: pit3.hansollvina.com" \
https://localhost/


#
curl -vk \
--resolve pit3.hansollvina.com:443:127.0.0.1 \
https://pit3.hansollvina.com/

#
curl -I https://pit3.hansollvina.com/
```
