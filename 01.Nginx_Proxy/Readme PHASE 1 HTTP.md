#

## PHASE 1: HTTP

### CẤU TRÚC

#### Luồng dữ liệu

```bash
Internet
   |
Firewall: TCP 80
   |
Nginx Docker trong DMZ
   |
   ├── pit.hansollvina.com     → PIT-IP:843
   ├── sims.hansollvina.com    → SIMS-IP:8888
   ├── subcon.hansollvina.com  → SUBCON-IP:8008
   ├── yte.hansollvina.com     → YTE-IP:8008
   └── hr.hansollvina.com      → HR-IP:PORT/đường-dẫn
```

#### Cấu trúc thư mục

```bash
nginx_proxy/
├── docker-compose.yml
├── nginx.conf
│
├── conf.d/
│   ├── pit.conf
│   ├── sims.conf
│   ├── subcon.conf
│   ├── yte.conf
│   └── hr.conf
│
├── snippets/
│   └── proxy-common.conf
│
└── logs/
    ├── pit/
    ├── sims/
    ├── subcon/
    ├── yte/
    └── hr/
```
#### File localtion

```bash
| Trên Docker host | Trong container         | Quyền      |
| ---------------- | ----------------------- | ---------- |
| `nginx.conf`     | `/etc/nginx/nginx.conf` | Chỉ đọc    |
| `conf.d/`        | `/etc/nginx/conf.d/`    | Chỉ đọc    |
| `snippets/`      | `/etc/nginx/snippets/`  | Chỉ đọc    |
| `logs/`          | `/var/log/nginx/`       | Đọc và ghi |
```
### THỰC HIỆN:
#### 1. Tạo khung các thư mục

```bash
cd /c
mkdir -p Bai_Nginx_Proxy
cd Bai_Nginx_Proxy

# các thư mục con
mkdir -p conf.d
mkdir -p snippets

mkdir -p logs/pit
mkdir -p logs/sims
mkdir -p logs/subcon
mkdir -p logs/yte
mkdir -p logs/hr

# kiểm tra kết quả
find . -maxdepth 3 -type d
```

#### 2. Tạo file:
- `docker-compose.yml`
- `nginx.conf`
- `proxy-common.conf`

- `subcon.conf`
- `sims.conf`
- `pit.conf`

```bash
# Kiểm tra cấu hình trước khi chạy
docker compose config

# Tạo container
docker compose up -d --build


# Kiểm tra trạng thái
docker compose ps
```
#### 3. TEST

```bash
# Test localhost
curl -I http://localhost

# Test nginx proxy
curl -I \
-H "Host: pit3.hansollvina.com" \
http://localhost/

# Chạy lệnh dưới, nếu thêm nginx proxy mới (ví dụ: hr.conf trong `conf.d`)
docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload

#
curl -I \
-H "Host: subcon.hansollvina.com" \
http://localhost/hsvn-subcontract/

#
curl -I \
-H "Host: subcon.hansollvina.com" \
http://localhost/hsvn-subcontract
```