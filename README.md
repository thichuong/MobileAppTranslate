# Mobile App Translate

A versatile, high-performance Flutter application for real-time translation and visual understanding. This app leverages on-device machine learning to provide instant text recognition, object detection, and multi-lingual translation without requiring a constant internet connection.

---

## ✨ Key Capabilities

- **🚀 Real-Time Vision**: 
  - **Stable AR Translation**: High-performance OCR with **Spatial Tracking (IoU)** and **Intelligent Cooldown** for jitter-free overlays.
  - **Smart Object Detection**: Dual-label (Source/Target) classification powered by EfficientNet-Lite.
- **🗣️ Voice & Text Hub**:
  - **Conversational STT**: Speech-to-text translation with support for 50+ locales.
  - **Natural TTS**: Listen to translations with high-quality text-to-speech.
- **🖼️ Static Analysis**: 
  - Analyze captured photos or import images from the gallery for deep offline processing.
- **⚡ Optimized Pipeline**:
  - **60 FPS** Camera Preview.
  - Throttled ML inference (~5-10 FPS) for battery efficiency and thermal management.

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (GetX for State Management)
- **ML Engine**: [Google ML Kit](https://developers.google.com/ml-kit) (Object Detection, Text Recognition, Translation)
- **Custom Models**: EfficientNet-Lite (TFLite integration)
- **Design System**: Modern Dark Mode UI with vibrant accents and micro-animations.

---

## 📂 Project Documentation

Detailed technical documentation is available in the `docs/` directory:

1.  **[System Architecture](docs/Architecture.md)**: Explore the modular GetX design, service layers, and ML processing pipeline.
2.  **[Features & Specifications](docs/Features.md)**: Deep dive into all user-facing functionalities and technical requirements.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Android Studio / Xcode

### Installation

1.  Clone the repository and navigate to the project root.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

---

*Developed with ❤️ by the Antigravity team.*
