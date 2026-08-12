#
Đôi khi bị lệnh giờ trong logs cần phải chỉnh

## Thực hiện

1. Chỉnh trong file `docker-compose.yml`
Thêm `environment` và `volumes`

```bash

services:

  nginx:
    image: ...
    container_name: ....
    
    # chỉnh múi giờ trong logs
    environment:
      - TZ=Asia/Ho_Chi_Minh

    volumes:

    # liên quan đến giờ và timezone
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
```
2. Khởi động và test
```bash
docker compose down
docker compose up -d --build
docker ps

docker exec nginx-proxy-v2 nginx -t
docker exec nginx-proxy-v2 nginx -s reload
```