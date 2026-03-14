# System Specification and Features

MobileAppTranslate is an all-in-one on-device intelligence tool designed for seamless linguistic communication and visual understanding.

## 🌟 Core Features

### 1. Universal Text Translation
- **Manual Input**: Multi-line text field with instant translation.
- **Voice Translation**: Integrated Speech-to-Text (STT) for hands-free input.
- **Vocal Output**: Text-to-Speech (TTS) support for translated results.
- **Offline Mode**: Uses on-device models for privacy and zero data usage.

### 2. Live OCR Vision (Live Translation)
- **Real-time Detection**: Recognizes text within the camera view at high speed.
- **In-place Overlay**: Replaces source text with translated text directly in the augmented reality view.
- **Spatial Stability**: Uses an IoU-based tracking engine to anchor translation boxes to real-world coordinates, eliminating jitter.
- **Intelligent Cooldown**: Configurable OCR stabilization that prevents "flickering" translations by locking results for a set duration.
- **Multi-Script Support**: Optimized recognition for Latin, Japanese, Chinese, Korean, and Devanagari.

### 3. Intelligent Object Detection
- **Bilingual Labeling**: Detects objects and displays names in both Source (IN) and Target (OUT) languages simultaneously.
- **English-First Pipeline**: Optimized to classify objects in English and provide dual translations for maximum accuracy.
- **Custom Models**: Supports 5 tiers of EfficientNet-Lite (Lite0 to Lite4) to balance speed and accuracy based on device capability.
- **Confidence Visualization**: Real-time confidence scores for every detected entity.

### 4. Image Analysis (Static)
- **Camera Capture**: Snap a photo and perform deep analysis on the static frame.
- **Gallery Import**: Pick existing images from the device library for OCR or object detection.

---

## 📋 Technical Specifications

| Component | Technology / Detail |
| :--- | :--- |
| **Minimum SDK** | Flutter 3.6.0+, Dart 3.3+ |
| **Model Engine** | Google ML Kit / TensorFlow Lite |
| **State Management** | GetX (Reactive) |
| **ML Performance** | 50ms - 200ms per frame (device dependent) |
| **Supported Languages** | 50+ languages via ML Kit Translation models |
| **Image Resolution** | Throttled to 720p/1080p for real-time processing |

---

## 🛠 Permission Requirements
- **Camera**: Required for live vision and photo capture.
- **Microphone**: Required for voice-to-text translation.
- **Storage**: Required for importing images from gallery and caching ML models.

---

## 🧭 Navigation & UX
- **Home Screen**: Fast access to text and voice translation.
- **Vision Hub**: Toggle between OCR and Object Detection modes.
- **Settings**: Adjust ML model tiers, processing FPS, and **OCR Cooldown (ms)** for personalized performance balancing.
