# Tuần 3 — Đóng gói & Tối ưu hóa Dockerfile

## Bảng so sánh số liệu qua từng bước tối ưu

| Bước tối ưu | Image Tag | Kích thước | Số Layer | Thời gian Build (lạnh / cache) | Ghi chú |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 0. Bản gốc | `py-api:v0-raw` | ~1.05 GB | 10 | ~40s / ~35s | Base `python:3.12` đầy đủ, copy cả `.venv` |
| 1. Tối ưu Cache | `py-api:v1-cache` | ~1.05 GB | 11 | ~40s / ~1.5s | Tách `COPY requirements.txt` lên trước |
| 2. Thêm `.dockerignore` | `py-api:v2-ignore` | ~1.01 GB | 11 | ~38s / ~1.2s | Loại bỏ `.venv`, `.git`, file test khỏi context |
| 3. Đổi Base Image | `py-api:v3-slim` / `alpine` | 155 MB / 65 MB | 9 / 9 | ~15s / ~1.0s | Giảm hơn 90% dung lượng so với bản gốc |
| 4. Multi-stage Build | `py-api:v4-multistage` | ~65 MB | 9 | ~20s / ~1.0s | Cài `build-base` ở stage builder, runtime chỉ giữ `venv` |
| 5. Bảo mật & Hoàn thiện | `py-api:v5-final` | ~65 MB | 10 | ~20s / ~1.0s | Chạy `appuser` (non-root), có `HEALTHCHECK`, `ENTRYPOINT` exec form |

## Ghi chú về Alpine và `musl libc`
- **Khác biệt cốt lõi:** Alpine sử dụng `musl libc` (thay vì `glibc` trên Ubuntu/Debian) và shell `ash` (thay vì `bash`).
- **Xử lý lỗi compile:** Các thư viện Python có mã nguồn C nhưng chưa có sẵn file wheel cho musl sẽ báo lỗi thiếu `gcc` khi `pip install`. Giải pháp là cài `apk add --no-cache build-base` ở stage `builder`, sau đó chỉ copy thư mục `/opt/venv` sang stage `runtime` để image cuối cùng không bị phình dung lượng.
