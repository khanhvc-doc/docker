#

## Mục tiêu
- Thêm web3 và không ảnh hưởng các web trước đó

## Thực hiện
- Copy nguyên bài 04 sang, chỉnh lại các port tương ứng 9110, 9111, 9112
- Tạo web3, port 9113 (tương tự bài 1)

Cấu trúc
```bash
web3/
    Dockerfile
    app.py
    requirements.txt
```
- Thêm server vào file `docker-compose.yml`
```YAML
web3:
  build: ./web3
  container_name: bai04_web3
  ports:
    - "9113:9113"
  networks:
    - web-network
```

- Sửa nginx
```YAML
location /web3/ {
    proxy_pass http://web3:9113/;
}
```

- Thực hiện build web
```bash
docker compose up -d --build web3 nginx
```

> Compose sẽ:
> - Build lại web3
> - Build lại nginx (vì nginx.conf thay đổi)
> - Restart nginx
> - Khởi động web3

- Các lệnh cần nhớ

| Thay đổi             | Lệnh                                      |
| -------------------- | ----------------------------------------- |
| Thêm web3            | `docker compose up -d --build web3 nginx` |
| Chỉ sửa web3         | `docker compose up -d --build web3`       |
| Chỉ sửa nginx.conf   | `docker compose up -d --build nginx`      |
| Sửa toàn bộ hệ thống | `docker compose up -d --build`            |
