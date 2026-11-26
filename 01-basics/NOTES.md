# Bài 1.1 — Vòng đời Container

## 1. Các thao tác cơ bản

- `docker run`: Tạo và chạy container.
- `docker ps`: Xem container đang chạy.
- `docker ps -a`: Xem tất cả container.
- `docker stop`: Dừng container.
- `docker start`: Khởi động container đã dừng.
- `docker restart`: Khởi động lại container.
- `docker rm`: Xóa container.

## 2. Làm việc với container

- `docker logs -f nginx-lab`: Theo dõi log trực tiếp.
- `docker exec -it nginx-lab sh`: Truy cập terminal bên trong container.
- `docker inspect`: Xem thông tin chi tiết container.
- `docker stats`: Theo dõi tài nguyên container.

## 3. Thực hành Nginx

Chạy Nginx bằng lệnh:

`docker run -d --name nginx-lab -p 8080:80 nginx:alpine`

Truy cập bằng:

`curl http://localhost:8080`

Kết quả: Nginx trả về trang web mặc định.

Sau đó sửa file `/usr/share/nginx/html/index.html` bên trong container. Khi restart container, nội dung đã sửa vẫn còn.

## 4. Kiểm tra dữ liệu khi xóa container

Sau khi xóa container cũ và tạo container mới từ image `nginx:alpine`, trang web trở về mặc định.

Nguyên nhân: Dữ liệu sửa đổi nằm trong writable layer của container. Khi xóa container, writable layer cũng bị xóa.

## 5. Cách lưu dữ liệu lâu dài

- Docker Volume: Lưu dữ liệu trong vùng do Docker quản lý.
- Bind Mount: Liên kết thư mục trên máy Ubuntu với thư mục bên trong container.

Hai cách này giúp dữ liệu tồn tại độc lập với vòng đời container.
## 6. Quan sát Container từ góc nhìn Linux

### PID Namespace
- Mỗi container có không gian PID riêng.
- Tiến trình Nginx có PID 1 bên trong container.
- Trên Ubuntu, PID 1 là systemd.
- Kiểm tra bằng `docker exec limit-lab ps aux`.

### Network Namespace
- Container có giao diện mạng riêng.
- Dùng `nsenter` để quan sát network namespace:
  `sudo nsenter -t <PID> -n ip addr`.

### Cgroups
- Cgroups dùng để giới hạn tài nguyên container.
- Container limit-lab được giới hạn:
  - RAM: 64 MiB.
  - CPU: 0.5 core.
- Kiểm tra RAM:
  `sudo cat /proc/<PID>/root/sys/fs/cgroup/memory.max`.
- Kết quả: 67108864 bytes (64 MiB).

### OOM (Out Of Memory)
- Khi container vượt giới hạn RAM, Linux có thể kích hoạt OOM Killer.
- `memory.events` ghi nhận số lần xảy ra OOM và OOM Kill.
- `OOMKilled` trong Docker inspect phản ánh trạng thái OOM của tiến trình chính container.
## 7. Docker Image và Layers

### Image và Container
- Image là bản mẫu chứa ứng dụng và môi trường chạy.
- Container là một phiên bản được tạo từ image.
- Một image có thể tạo nhiều container.

### So sánh Python Images
| Image | Disk Usage |
|---|---:|
| python:3.12 | 1.62GB |
| python:3.12-slim | 179MB |
| python:3.12-alpine | 74.7MB |

- Bản đầy đủ chứa nhiều thành phần hệ thống.
- Slim tối giản hơn.
- Alpine sử dụng Alpine Linux nên có dung lượng nhỏ.

### Layers
- Image được cấu thành từ nhiều layer.
- docker history: Xem lịch sử các layer.
- Các layer giúp Docker tái sử dụng dữ liệu và tiết kiệm dung lượng.

### Docker Commit
- docker commit: Lưu thay đổi filesystem của container thành image mới.
- Không nên lạm dụng vì khó tái tạo và quản lý.
- Thực tế nên dùng Dockerfile và docker build.

### Docker Save và Load
- docker save: Xuất image thành file TAR.
- docker load: Nạp image từ file TAR.
- Đã thực hành với python-custom:v1.

### Gitignore
- Quy tắc *.tar giúp Git bỏ qua các file TAR.
- Không nên đưa Docker image dung lượng lớn vào Git repository.
## 8. Docker Cleanup Script

- Tạo script Bash để tự động dọn dẹp Docker.
- `docker ps -aq --filter "status=exited"`: Lấy danh sách container đã dừng.
- `docker inspect`: Kiểm tra thời điểm container dừng.
- Chỉ chọn container đã dừng hơn 24 giờ.
- `docker images -f dangling=true`: Liệt kê dangling images.
- Script hỏi xác nhận trước khi xóa tài nguyên.
- `chmod +x`: Cấp quyền thực thi cho script.
- `bash -n`: Kiểm tra cú pháp Bash.
