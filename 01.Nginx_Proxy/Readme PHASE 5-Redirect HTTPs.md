# Mục tiêu:

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

- Khởi động lại và test

```bash
docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload

```