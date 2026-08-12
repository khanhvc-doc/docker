# Redirect
http to https

## Mục tiêu 1:

Khi user dùng http tự động đẩy về https

```bash
HTTP :80
   ↓
KHÔNG proxy backend nữa
   ↓
301 → HTTPS :443
   ↓
Nginx HTTPS
   ↓
proxy_pass
   ↓
192.168.99.32:4003
```

## Thực hiện

- Tìmm server block HTTP listen 80
```bash
    location / {
        proxy_pass http://192.168.99.20:8008/hsvn-subcontract/;
        include /etc/nginx/snippets/proxy-common.conf;

    }
```

thay bằng

```bash
location / {
    return 301 https://subcon3.hansollvina.com$request_uri;
}
```

HOẶC:
```bash
    location / {
        return 301 https://$host$request_uri;

    }
```

- Khởi động lại và test

```bash
docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload

```
## Mục tiêu 2:
```bash
HTTP :80 / 9009
   ↓
KHÔNG proxy backend nữa
   ↓
301 → HTTPS :443
   ↓
Nginx HTTPS
   ↓
proxy_pass
   ↓
192.168.99.32:4003
```

## THỰC HIỆN

1. Thêm port 9009 vào file `docker-compose.yml`
```yaml
ports:
  - "80:80"
  - "443:443"
  - "9009:9009" 
```
2. Thêm vào file **.conf** 

```bash
server {
    listen 80;
    listen 9009;   # <-- thêm dòng này, port http muốn lắng nghe
    server_name ai3.hansollvina.com ai2.hansollvina.com ai.hansollvina.com;
   ...
   ...
}
```
3. Build lại

```bash
docker compose down
docker compose up -d --build
docker ps

docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload

```

4. Test

```bash
curl -Ik http://localhost:9009/ -H "Host: ai.hansollvina.com"
```

kết quả OK sẽ là
```bash
HTTP/1.1 301 Moved Permanently
Location: https://ai.hansollvina.com/
```