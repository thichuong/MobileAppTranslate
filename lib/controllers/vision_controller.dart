import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/translate_controller.dart';
import '../services/camera_service.dart';
import '../services/vision_service.dart';
import '../services/translation_service.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'settings_controller.dart';
import '../utils/image_utils.dart';
import 'mixins/vision_smoothing_mixin.dart';


enum VisionMode { text, object }

class VisionController extends GetxController with VisionSmoothingMixin {
  final CameraService _cameraService = Get.find<CameraService>();
  final VisionService _visionService = Get.find<VisionService>();
  final TranslationService _translationService = Get.find<TranslationService>();
  final TranslateController _translateController = Get.find<TranslateController>();

  final Rx<VisionMode> mode = VisionMode.text.obs;
  final RxBool isActionBusy = false.obs; // For UI actions like capture/pick
  final RxBool _isDetecting = false.obs; // Internal for framing
  bool _shouldStopDetection = false;
  final RxBool isLive = true.obs;
  final Rx<String?> imagePath = Rx<String?>(null);

  final ImagePicker _picker = ImagePicker();

  // Throttle: detection chạy ở FPS được cấu hình để tiết kiệm năng lượng
  int get _detectionIntervalMs => 1000 ~/ Get.find<SettingsController>().processingFps.value;
  final Stopwatch _frameStopwatch = Stopwatch();

  // Results
  final Rx<RecognizedText?> recognizedText = Rx<RecognizedText?>(null);
  final RxList<DetectedObject> detectedObjects = <DetectedObject>[].obs;

  // Translation Results
  final RxMap<String, String> translatedTextBlocks = <String, String>{}.obs;
  final RxMap<String, String> translatedLabels = <String, String>{}.obs; // Primary (Target)
  final RxMap<String, String> sourceTranslatedLabels = <String, String>{}.obs; // For Object Detection (Input)


  // Caching for immediate capture feedback
  RecognizedText? _lastRecognizedText;
  List<DetectedObject> _lastDetectedObjects = [];

  // Camera metadata for painter
  final Rx<Size?> _imageSize = Rx<Size?>(null);
  Size? get imageSize => _imageSize.value;

  final Rx<InputImageRotation?> _imageRotation = Rx<InputImageRotation?>(null);
  InputImageRotation? get imageRotation => _imageRotation.value;

  @override
  void onInit() {
    super.onInit();
    startLiveFeed();

    // Re-init translator when languages change
    ever(_translateController.sourceLanguage, (_) => _initTranslator());
    ever(_translateController.targetLanguage, (_) => _initTranslator());
    _initTranslator();
  }

  Future<void> _initTranslator() async {
    await _translationService.initTranslator(
      sourceLanguage: _translateController.sourceLanguage.value,
      targetLanguage: _translateController.targetLanguage.value,
    );

    // Clear caches when language changes
    translatedTextBlocks.clear();
    translatedLabels.clear();
    sourceTranslatedLabels.clear();
  }

  Future<void> startLiveFeed() async {
    isLive.value = true;
    final settings = Get.find<SettingsController>();
    await _visionService.initCustomDetector(
        model: settings.selectedModel.value);
    await _cameraService.initializeController();
    _frameStopwatch.reset();
    _frameStopwatch.start();
    _cameraService.controller?.startImageStream(_onCameraFrame);
    update();
  }

  Future<void> stopLiveFeed({bool cleanup = false}) async {
    isLive.value = false;
    _frameStopwatch.stop();
    _frameStopwatch.reset();
    if (_cameraService.controller?.value.isStreamingImages ?? false) {
      await _cameraService.controller?.stopImageStream();
    }
    if (cleanup) {
      await _visionService.closeRecognizers();
    }
  }

  void toggleMode() {
    mode.value = mode.value == VisionMode.text
        ? VisionMode.object
        : VisionMode.text;

    // Clear results on mode switch
    recognizedText.value = null;
    detectedObjects.clear();
    _lastRecognizedText = null;
    _lastDetectedObjects = [];

    // Re-scan if looking at a static image
    if (!isLive.value && imagePath.value != null) {
      _processStaticImage(imagePath.value!);
    }
  }

  void sendToTranslate() {
    String textToSend = "";

    if (mode.value == VisionMode.text) {
      if (recognizedText.value != null) {
        textToSend = recognizedText.value!.text;
      }
    } else {
      if (detectedObjects.isNotEmpty) {
        // Collect labels from detected objects - use source translated labels (IN)
        final labels = detectedObjects
            .expand((obj) => obj.labels)
            .where((label) => label.confidence > 0.5)
            .map((label) {
              final normalized = label.text.toLowerCase().trim();
              return sourceTranslatedLabels[normalized] ?? label.text;
            })
            .toSet()
            .toList();
        textToSend = labels.join(", ");
      }
    }

    if (textToSend.trim().isEmpty) {
      Get.snackbar("No text", "No results found to translate.");
      return;
    }

    final translateController = Get.find<TranslateController>();
    translateController.inputText.value = textToSend;
    translateController.textEditingController.text = textToSend;

    Get.back(); // Return to main screen
  }

  /// Callback nhẹ cho mỗi camera frame — chỉ check throttle, không xử lý nặng
  void _onCameraFrame(CameraImage image) {
    if (_isDetecting.value || _shouldStopDetection) return;
    if (_frameStopwatch.elapsedMilliseconds < _detectionIntervalMs) return;
    _frameStopwatch.reset();
    _processFrame(image);
  }

  /// Xử lý detection trên frame được chọn (~5 FPS)
  /// Kỹ thuật "2 luồng": Dart UI thread gửi ảnh gốc qua Native thread xử lý,
  /// giúp UI/Camera preview luôn mượt (~60 FPS) trong khi detection chạy ngầm.
  Future<void> _processFrame(CameraImage image) async {
    _isDetecting.value = true;

    final inputImage = ImageUtils.inputImageFromCameraImage(
      image: image,
      controller: _cameraService.controller!,
      cameras: _cameraService.cameras,
    );
    if (inputImage == null || _shouldStopDetection) {
      _isDetecting.value = false;
      return;
    }

    _imageSize.value = Size(image.width.toDouble(), image.height.toDouble());
    _imageRotation.value = inputImage.metadata?.rotation;

    try {
      if (mode.value == VisionMode.text) {
        final results = await _visionService.recognizeText(inputImage);
        if (_shouldStopDetection) return;
        
        final processedResults = smoothTextResults(results);
        // Translate before showing results — paint chỉ xảy ra sau bước này
        await _translateTextBlocks(processedResults);
        if (_shouldStopDetection) return;

        // Clear kết quả cũ trước khi gán mới
        recognizedText.value = null;
        recognizedText.value = processedResults;
        _lastRecognizedText = processedResults;
      } else {
        final results = await _visionService.detectObjects(inputImage);
        if (_shouldStopDetection) return;
        
        // Translate before showing results — paint chỉ xảy ra sau bước này
        await _translateObjectLabels(results);
        if (_shouldStopDetection) return;

        // Clear kết quả cũ trước khi gán mới
        detectedObjects.clear();
        detectedObjects.value = results;
        _lastDetectedObjects = results;
      }
    } catch (e) {
      debugPrint("Vision error: $e");
    } finally {
      _isDetecting.value = false;
    }
  }


  Future<void> _translateTextBlocks(RecognizedText results) async {
    final futures = <Future>[];
    for (final block in results.blocks) {
      // Normalize text: lowercase, trim, remove non-alphanumeric at start/end
      final normalized = normalizeText(block.text);
      if (normalized.isEmpty || translatedTextBlocks.containsKey(normalized)) continue;

      // Throttle: avoid too many items
      if (translatedTextBlocks.length > 100) translatedTextBlocks.clear();

      futures.add(_translationService.translateText(normalized).then((translated) {
        if (translated.isNotEmpty && !translated.startsWith("Translation error")) {
          translatedTextBlocks[normalized] = translated;
        }
      }));
    }
    await Future.wait(futures);
  }


  Future<void> _translateObjectLabels(List<DetectedObject> objects) async {
    final labelsToTranslate = objects
        .expand((obj) => obj.labels)
        .where((l) => l.confidence >= VisionService.confidenceThreshold)
        .map((l) => l.text.toLowerCase().trim())
        .toSet();

    final futures = <Future>[];
    for (final label in labelsToTranslate) {
      // 1. Translate to Target (translatedLabels)
      if (!translatedLabels.containsKey(label)) {
        futures.add(_translationService.translateText(label).then((translated) {
          if (translated.isNotEmpty && !translated.startsWith("Translation error")) {
            translatedLabels[label] = translated;
          }
        }));
      }

      // 2. Translate to Source (sourceTranslatedLabels)
      if (!sourceTranslatedLabels.containsKey(label)) {
        futures.add(_translationService
            .translateBetween(label,
                source: TranslateLanguage.english,
                target: _translateController.sourceLanguage.value)
            .then((translated) {
          if (translated.isNotEmpty) {
            sourceTranslatedLabels[label] = translated;
          }
        }));
      }
    }
    await Future.wait(futures);
  }

  Future<void> captureImage() async {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return;
    }

    try {
      isActionBusy.value = true;
      _shouldStopDetection = true;

      // Clear smoothing caches — ảnh tĩnh không cần ghost blocks
      clearSmoothingCaches();

      // Lấy ngay kết quả cuối cùng từ cache
      if (mode.value == VisionMode.text) {
        recognizedText.value = _lastRecognizedText;
      } else {
        detectedObjects.value = _lastDetectedObjects;
      }

      // Dừng stream ngay lập tức
      if (_cameraService.controller?.value.isStreamingImages ?? false) {
        await _cameraService.controller?.stopImageStream();
      }

      final XFile file = await _cameraService.controller!.takePicture();
      imagePath.value = file.path;
      await stopLiveFeed(cleanup: true);
    } catch (e) {
      debugPrint("Capture error: $e");
    } finally {
      isActionBusy.value = false;
      _shouldStopDetection = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        isActionBusy.value = true;
        imagePath.value = image.path;
        await stopLiveFeed();
        await _processStaticImage(image.path);
      }
    } catch (e) {
      debugPrint("Picker error: $e");
    } finally {
      isActionBusy.value = false;
    }
  }


  Future<void> _processStaticImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);

    // Get image size for the painter
    final bytes = await File(path).readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final decodedImage = fi.image;

    _imageSize.value =
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    _imageRotation.value = InputImageRotation.rotation0deg;

    try {
      if (mode.value == VisionMode.text) {
        final results = await _visionService.recognizeTextSingle(inputImage);
        await _translateTextBlocks(results);
        recognizedText.value = results;
      } else {
        final results = await _visionService.detectObjectsSingle(inputImage);
        await _translateObjectLabels(results);
        detectedObjects.assignAll(results);
      }
    } catch (e) {
      debugPrint("Static processing error: $e");
    }
  }


  @override
  void onClose() {
    stopLiveFeed();
    super.onClose();
  }
}
