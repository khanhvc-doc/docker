#

## Bài 03:

### Trên Ubuntu
```bash
docker run -d \
--name nginx \
-p 9000:9000 \
-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
--network web-network \
nginx
```

- `-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro`: Gắn ổ đĩa (Volume binding).
- `$(pwd)/nginx.conf`: Lấy file nginx.conf tại thư mục hiện tại bạn đang đứng (pwd - print working directory).
- `/etc/nginx/nginx.conf`: Đường dẫn file cấu hình mặc định bên trong container. Thao tác này sẽ dùng file của bạn để đè lên file cấu hình gốc.
- `:ro (read-only)`: Cấp quyền chỉ đọc. Đảm bảo Nginx bên trong container không thể vô tình sửa đổi hay xóa file cấu hình gốc trên máy host của bạn.
- `--network web-network`: Tạo trực tiếp `web-network` khi tạo image

### Trên Windows
```bash
docker run -d \
  --name nginx \
  --network web-network \
  -p 9000:9000 \
  -v "D:\\vck\\HocHanh\\01.Udemy\\01.docker\\00.Python_Project\\Bai_03\\nginx.conf:/etc/nginx/nginx.conf:ro" \
  nginx
```