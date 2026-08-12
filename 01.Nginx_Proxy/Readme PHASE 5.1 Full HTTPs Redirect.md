#

## MỤC TIÊU
- Tạo HTTP redirect HTTPS cho node mới

## THỰC HIỆN

1. Tạo thưc mục để chứa log trong `logs`. Ví dụ: logs\vck
2. Soạn file .conf trong thư mục `conf.d`. Ví dụ: conf.d\vck.conf
```bash
server {
    listen 80;
    server_name 
        vck3.hansollvina.com
        vck2.hansollvina.com;

    access_log /var/log/nginx/vck/access.log main;
    error_log  /var/log/nginx/vck/error.log;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name
        vck3.hansollvina.com
        ai2.hansollvina.com;

    ssl_certificate     /etc/letsencrypt/live/vck3.hansollvina.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/vck3.hansollvina.com/privkey.pem;

    access_log /var/log/nginx/vck/ssl_access.log main;
    error_log  /var/log/nginx/vck/ssl_error.log;

    location / {
        proxy_pass http://192.168.131.15:9009;
        include /etc/nginx/snippets/proxy-common.conf;
    }
}
```

3. Xin CA
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
  --cert-name vck3.hansollvina.com \
  --expand \
  -d vck3.hansollvina.com \
  -d vck2.hansollvina.com

```
4. Khởi tạo và test
```bash
docker compose down
docker compose up -d --build
docker ps

docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload

```
```bash
curl -Ik \
-H "Host: vck3.hansollvina.com" \
https://localhost/
```

