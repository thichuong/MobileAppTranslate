# Mobile App Translate

Ứng dụng Flutter hỗ trợ dịch thuật qua camera và nhận diện vật thể với hiệu suất cao.

## ✨ Tính năng nổi bật (Vision)

- **Dịch văn bản trực tiếp (Text Vision)**: Nhận diện và dịch văn bản trực gian thực với giao diện overlay mượt mà.
- **Nhận diện vật thể (Object Detection)**: Phân loại vật thể nhanh chóng qua camera.
- **Chụp ảnh thông minh**: Chuyển đổi mượt mà từ preview trực tiếp sang ảnh tĩnh mà không làm mất kết quả nhận diện.
- **Tối ưu hiệu suất**:
  - Live Camera Preview chạy ở **60fps**.
  - Pipeline xử lý ML chạy ở **~5fps** để tiết kiệm pin và tránh lag UI.
  - Phân tách luồng xử lý và hiển thị.

## 🛠 Tech Stack

- **Framework**: Flutter (GetX for State Management)
- **ML Engine**: Google ML Kit (Object Detection, Text Recognition, Translation)
- **Camera**: `camera` package với các tùy chỉnh tối ưu cho Android/iOS.
- **Design**: Modern Dark UI (Vibrant colors, smooth animations).

## 🚀 Cấu trúc dự án

- `lib/controllers/`: Chứa logic điều khiển (VisionController, SettingsController).
- `lib/services/`: Các dịch vụ xử lý nền (CameraService, VisionService).
- `lib/views/`: Giao diện người dùng.
- `docs/`: Tài liệu kiến trúc dự án (Xem [Architecture.md](docs/Architecture.md)).

## 📦 Cài đặt

1. Đảm bảo đã cài đặt Flutter SDK.
2. Chạy `flutter pub get` để tải dependencies.
3. Chạy lệnh:
```bash
flutter run
```

---
*Phát triển bởi team Antigravity.*
