import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Enum cho 5 biến thể EfficientNet-Lite
enum EfficientNetModel {
  lite0('EfficientNet-Lite0', 'assets/ml/efficientnet_lite0.tflite'),
  lite1('EfficientNet-Lite1', 'assets/ml/efficientnet_lite1.tflite'),
  lite2('EfficientNet-Lite2', 'assets/ml/efficientnet_lite2.tflite'),
  lite3('EfficientNet-Lite3', 'assets/ml/efficientnet_lite3.tflite'),
  lite4('EfficientNet-Lite4', 'assets/ml/efficientnet_lite4.tflite');

  const EfficientNetModel(this.displayName, this.assetPath);
  final String displayName;
  final String assetPath;

  static EfficientNetModel fromString(String name) {
    return EfficientNetModel.values.firstWhere(
      (e) => e.name == name,
      orElse: () => EfficientNetModel.lite4,
    );
  }
}

class VisionService extends GetxService {
  TextRecognizer? _textRecognizer;
  ObjectDetector? _objectDetector;
  EfficientNetModel _currentModel = EfficientNetModel.lite4;
  TextRecognitionScript _currentScript = TextRecognitionScript.latin;

  // Confidence threshold và max labels — dùng ở UI layer để lọc kết quả
  static const double confidenceThreshold = 0.5;
  static const int maxLabelsPerObject = 3;

  EfficientNetModel get currentModel => _currentModel;

  /// Khởi tạo Text Recognizer với script được chỉ định
  Future<void> initTextRecognizer(
      {TextRecognitionScript script = TextRecognitionScript.latin}) async {
    if (_textRecognizer != null && _currentScript != script) {
      await _textRecognizer?.close();
      _textRecognizer = null;
    }

    if (_textRecognizer == null) {
      _currentScript = script;
      _textRecognizer = TextRecognizer(script: _currentScript);
    }
  }

  /// Khởi tạo Object Detector với model được chỉ định
  Future<void> initCustomDetector({EfficientNetModel? model}) async {
    model ??= _currentModel;
    _currentModel = model;

    // Đóng detector cũ trước khi tạo mới
    await _objectDetector?.close();
    _objectDetector = null;

    final modelPath = await _getModelPath(model.assetPath);

    final options = LocalObjectDetectorOptions(
      // Chế độ stream để nhận diện liên tục
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );

    _objectDetector = ObjectDetector(options: options);
  }

  /// Chuyển đổi model — đóng detector cũ và tạo mới
  Future<void> switchModel(EfficientNetModel model) async {
    if (model == _currentModel && _objectDetector != null) return;
    await initCustomDetector(model: model);
  }

  /// Copy model từ Flutter assets ra application support directory
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

  /// Recognize text (Stream mode)
  Future<RecognizedText> recognizeText(InputImage inputImage,
      {TextRecognitionScript? script}) async {
    await initTextRecognizer(script: script ?? _currentScript);
    return await _textRecognizer!.processImage(inputImage);
  }

  /// Recognize text (Single image mode)
  Future<RecognizedText> recognizeTextSingle(InputImage inputImage,
      {TextRecognitionScript? script}) async {
    await initTextRecognizer(script: script ?? _currentScript);
    return await _textRecognizer!.processImage(inputImage);
  }

  /// Detect objects sử dụng EfficientNet-Lite custom model (stream mode)
  Future<List<DetectedObject>> detectObjects(InputImage inputImage) async {
    if (_objectDetector == null) await initCustomDetector();
    return await _objectDetector!.processImage(inputImage);
  }

  /// Detect objects trên ảnh tĩnh — dùng DetectionMode.single
  Future<List<DetectedObject>> detectObjectsSingle(
      InputImage inputImage) async {
    final modelPath = await _getModelPath(_currentModel.assetPath);
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.single,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    final detector = ObjectDetector(options: options);
    try {
      return await detector.processImage(inputImage);
    } finally {
      await detector.close();
    }
  }

  Future<void> closeRecognizers() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
    await _objectDetector?.close();
    _objectDetector = null;
  }

  @override
  void onClose() {
    closeRecognizers();
    super.onClose();
  }
}
