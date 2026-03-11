# Vision System Architecture

Hệ thống thị giác (Vision) được thiết kế để cung cấp trải nghiệm real-time mượt mà (60fps) trong khi vẫn duy trì hiệu suất xử lý ML ổn định và tiết kiệm năng lượng.

## 1. Pipeline Xử lý Camera & Detection

Để tối ưu hóa, pipeline được chia thành hai luồng độc lập:

### Camera Preview (Native)
- Sử dụng widget `CameraPreview` của thư viện `camera`.
- Chạy ở mức **60 FPS** (native code), không bị ảnh hưởng bởi Dart event loop.
- Luôn đảm bảo độ mượt tối đa cho người dùng.

### Detection Processing (Throttled)
- Chạy ở mức **~5 FPS** (mỗi 200ms xử lý 1 frame).
- Sử dụng `Stopwatch` trong `VisionController` để điều phối (Throttle).
- **Callback `_onCameraFrame`**: Chạy 60 lần/giây nhưng trả về ngay lập tức (~1μs) nếu chưa đủ thời gian interval hoặc đang bận xử lý (isBusy).
- **Function `_processFrame`**: Chỉ được gọi khi frame vượt qua bộ lọc throttle. Thực hiện chuyển đổi `CameraImage` sang `InputImage` và gọi ML Kit.

## 2. Giao diện Live vs Capture

Hệ thống đảm bảo trải nghiệm thống nhất giữa chế độ live (camera) và chế độ xem ảnh chụp (capture):

- **Kích thước (Fit)**: Cả `CameraPreview` và `Image.file` (chế độ xem tĩnh) đều sử dụng `BoxFit.cover` để chiếm toàn bộ vùng hiển thị được chỉ định.
- **Tọa độ (Coordinates)**: Vì kích thước hiển thị khớp nhau, các bounding boxes (từ OCR/Object Detection) được vẽ bằng cùng một hệ tọa độ trên toàn màn hình.
- **Chuyển tải kết quả**: Khi người dùng nhấn "Chụp ảnh", `VisionController` chủ động giữ lại kết quả detection cuối cùng của luồng live. Hệ thống không thực hiện redetection trên ảnh chụp để tránh độ trễ và giật lag, tạo cảm giác chuyển cảnh tức thời.

## 3. Quản lý Trạng thái (GetX)

- **`VisionController`**: Điều phối chính, quản lý vòng đời camera, pipeline xử lý và kết quả hiển thị.
- **`VisionService`**: Wrapper cho Google ML Kit (Text Translation, Object Detection). Cung cấp các phương thức `detectObjects()` (stream) và `detectObjectsSingle()` (cấu hình chuyên biệt cho ảnh tĩnh).
- **`CameraService`**: Quản lý `CameraController` và các thiết lập phần cứng.

## 4. Fixes & Optimizations
- **Android Crash Fix**: Dừng hoàn toàn image stream trước khi thực hiện `takePicture()`.
- **Memory Efficiency**: Sử dụng `Stopwatch` (không delegate object) thay vì `DateTime` để giảm áp lực lên Garbage Collector (GC).
