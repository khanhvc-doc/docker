#

## Bài 4: 
Docker Compose (quản lý toàn bộ stack bằng một file).

### Mục tiêu:
- Hiểu Docker Compose là gì.
- Biết khi nào dùng `docker run`, khi nào dùng `docker compose`.
- Triển khai toàn bộ hệ thống bằng **một file duy nhất**.
- Chỉ cần một lệnh để khởi động hoặc dừng toàn bộ hệ thống.

### Ý tưởng 

Đến bài 3, đã làm được bằng docker CLI
```bash
Docker CLI
    │
    ├── docker network create
    │
    ├── docker run web1
    │
    ├── docker run web2s
    │
    └── docker run nginx
```

- Docker Compose chỉ đơn giản là **ghi tất cả các lệnh trên vào một file YAML**.
- Nó **không thay thế** Docker **mà điều khiển** Docker.
- Docker Compose sẽ làm:
```bash
Build web1
↓
Build web2
↓
Create Network
↓
Run web1
↓
Run web2
↓
Run nginx
```

bằng lệnh duy nhất:
```bash
docker compose up -d
```

### Cấu trúc lưu trữ:
```bash
Bai_04/
│
├── docker-compose.yml
│
├── web1/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── web2/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
└── nginx
    ├── Dockerfile
    └── nginx.conf
```

### Thực hiện:

#### Phần 1: 

- Cấu trúc `docker-compose.yml` và khai báo các service.
- Nội dung file YAML trong file `docker-compose_phan_1.yml`

#### Phần 2: Thêm build, ports.
**Compose** mới biết khung của `web1, 2, nginx` nhưng chưa biết: 
- Web1 mở cổng nào?
- Web2 mở cổng nào?
- Nginx mở cổng nào?
- Có network không?
- Có volume không?


#### Phần 3: Network & Volume
- Tạo `web-network` và connect container khi chạy lệnh **docker compose up -d**
- Tạm thời source code web1, 2, nginx bên trong container (chưa dùng Volume trong phần này)

#### Phần 4: Làm việc với Compose
- Học các lệnh quản trị Compose (up, down, ps, logs, restart, exec) và so sánh với Docker CLI.
```bash
docker compose up -d
```
- Kết quả tương tự bài 1, 2, 3
- Test
```bash
http://localhost:9011/
http://localhost:9012/
http://localhost:9010/web1/
http://localhost:9010/web2/
```


#### Them:
Để xóa các image có thể dùng docker rmi

#### Quy tắc cần nhớ file `docker-ompose.YML`

Có 2 cách khai báo network:

- **Cách 1** - List (khuyên dùng):

```bash
networks:
  - web-network
```

*Không có dấu :.*

- **Cách 2** - Mapping:

```bash
networks:
  web-network:
```

*Có dấu :, nhưng không có dấu -.*