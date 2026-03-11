import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class VisionService extends GetxService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  ObjectDetector? _objectDetector;

  // Confidence threshold và max labels — dùng ở UI layer để lọc kết quả
  static const double confidenceThreshold = 0.5;
  static const int maxLabelsPerObject = 3;

  /// Khởi tạo Object Detector với EfficientNet-Lite custom model
  Future<void> initCustomDetector() async {
    final modelPath = await _getModelPath('assets/ml/efficientnet_lite0.tflite');

    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );

    _objectDetector = ObjectDetector(options: options);
  }

  /// Copy model từ Flutter assets ra application support directory
  /// (ML Kit yêu cầu đường dẫn filesystem thực, không đọc được từ assets trực tiếp)
  Future<String> _getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return file.path;
  }

  Future<RecognizedText> recognizeText(InputImage inputImage) async {
    return await _textRecognizer.processImage(inputImage);
  }

  /// Detect objects sử dụng EfficientNet-Lite custom model
  Future<List<DetectedObject>> detectObjects(InputImage inputImage) async {
    if (_objectDetector == null) await initCustomDetector();
    return await _objectDetector!.processImage(inputImage);
  }

  Future<void> closeRecognizers() async {
    await _textRecognizer.close();
    await _objectDetector?.close();
  }

  @override
  void onClose() {
    closeRecognizers();
    super.onClose();
  }
}
