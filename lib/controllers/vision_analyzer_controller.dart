import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:camera/camera.dart';

import '../services/vision_service.dart';
import '../services/translation_service.dart';
import '../controllers/translate_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/image_utils.dart';
import '../utils/vision_results_processor.dart';
import '../models/tracked_text_block.dart';
import 'camera_manager_controller.dart';

enum VisionMode { text, object }

class VisionAnalyzerController extends GetxController {
  final VisionService _visionService = Get.find<VisionService>();
  final TranslationService _translationService = Get.find<TranslationService>();
  final TranslateController _translateController = Get.find<TranslateController>();
  final SettingsController _settingsController = Get.find<SettingsController>();
  
  final VisionResultsProcessor processor = VisionResultsProcessor();

  final Rx<VisionMode> mode = VisionMode.text.obs;
  final RxBool isDetecting = false.obs;
  
  // Results
  final RxList<TrackedTextBlock> trackedTextBlocks = <TrackedTextBlock>[].obs;
  final RxList<DetectedObject> detectedObjects = <DetectedObject>[].obs;
  
  // Translation Caches
  final RxMap<String, String> translatedTextBlocks = <String, String>{}.obs;
  final RxMap<String, String> translatedLabels = <String, String>{}.obs;
  final RxMap<String, String> sourceTranslatedLabels = <String, String>{}.obs;

  // Metadata for painting
  final Rx<Size?> imageSize = Rx<Size?>(null);
  final Rx<InputImageRotation?> imageRotation = Rx<InputImageRotation?>(null);
  final RxBool isTranslatorReady = false.obs;

  final Stopwatch _frameStopwatch = Stopwatch();
  int get _detectionIntervalMs => 1000 ~/ _settingsController.processingFps.value;

  @override
  void onInit() {
    super.onInit();
    _frameStopwatch.start();
    
    // Initial and reactive translator setup
    _initTranslator();
    ever(_translateController.sourceLanguage, (_) => _initTranslator());
    ever(_translateController.targetLanguage, (_) => _initTranslator());
    
    // Link OCR Cooldown setting to processor
    processor.setOcrCooldown(_settingsController.ocrCooldown.value);
    ever(_settingsController.ocrCooldown, (int ms) => processor.setOcrCooldown(ms));
  }

  Future<void> _initTranslator() async {
    isTranslatorReady.value = false;
    await _translationService.initTranslator(
      sourceLanguage: _translateController.sourceLanguage.value,
      targetLanguage: _translateController.targetLanguage.value,
    );
    isTranslatorReady.value = true;
    _clearCaches();
  }

  void _clearCaches() {
    translatedTextBlocks.clear();
    translatedLabels.clear();
    sourceTranslatedLabels.clear();
  }

  void onCameraFrame(CameraImage image) {
    if (isDetecting.value || !isTranslatorReady.value) return;
    if (_frameStopwatch.elapsedMilliseconds < _detectionIntervalMs) return;
    
    _frameStopwatch.reset();
    _frameStopwatch.start();
    
    isDetecting.value = true;
    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    final cameraManager = Get.find<CameraManagerController>();
    if (cameraManager.controller == null) {
      isDetecting.value = false;
      return;
    }

    final inputImage = ImageUtils.inputImageFromCameraImage(
      image: image,
      controller: cameraManager.controller!,
      cameras: cameraManager.cameras,
    );

    if (inputImage == null) {
      isDetecting.value = false;
      return;
    }

    imageSize.value = Size(image.width.toDouble(), image.height.toDouble());
    imageRotation.value = inputImage.metadata?.rotation;

    try {
      if (mode.value == VisionMode.text) {
        final script = _getScriptFromLanguage(_translateController.sourceLanguage.value);
        final results = await _visionService.recognizeText(inputImage, script: script);
        
        final processedResults = processor.smoothTextResults(results);
        await _translateTextBlocks(processedResults);
        trackedTextBlocks.assignAll(processedResults);
      } else {
        final results = await _visionService.detectObjects(inputImage);
        await _translateObjectLabels(results);
        detectedObjects.value = results;
      }
    } catch (e) {
      debugPrint("Vision analysis error: $e");
    } finally {
      isDetecting.value = false;
    }
  }

  TextRecognitionScript _getScriptFromLanguage(TranslateLanguage lang) {
    switch (lang) {
      case TranslateLanguage.japanese: return TextRecognitionScript.japanese;
      case TranslateLanguage.korean: return TextRecognitionScript.korean;
      case TranslateLanguage.chinese: return TextRecognitionScript.chinese;
      case TranslateLanguage.hindi: return TextRecognitionScript.devanagiri;
      default: return TextRecognitionScript.latin;
    }
  }

  Future<void> _translateTextBlocks(List<TrackedTextBlock> blocks) async {
    final futures = <Future>[];
    for (final block in blocks) {
      final id = block.id;
      final text = block.text.trim();
      
      if (text.isEmpty || translatedTextBlocks.containsKey(id)) continue;

      futures.add(_translationService.translateText(text).then((translated) {
        if (translated.isNotEmpty && !translated.startsWith("Translation error")) {
          translatedTextBlocks[id] = translated;
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

    final sourceLang = _translateController.sourceLanguage.value;
    final targetLang = _translateController.targetLanguage.value;

    final futures = <Future>[];
    for (final label in labelsToTranslate) {
      // 1. Translate to OUT (Target) - ML Kit labels are English
      if (!translatedLabels.containsKey(label)) {
        futures.add(_translationService
            .translateBetween(label,
                source: TranslateLanguage.english, target: targetLang)
            .then((translated) {
          if (translated.isNotEmpty &&
              !translated.startsWith("Translation error")) {
            translatedLabels[label] = translated;
          }
        }));
      }

      // 2. Translate to IN (Source) if Source is not English
      if (sourceLang != TranslateLanguage.english) {
        if (!sourceTranslatedLabels.containsKey(label)) {
          futures.add(_translationService
              .translateBetween(label,
                  source: TranslateLanguage.english, target: sourceLang)
              .then((translated) {
            if (translated.isNotEmpty &&
                !translated.startsWith("Translation error")) {
              sourceTranslatedLabels[label] = translated;
            }
          }));
        }
      } else {
        // If source is English, use the original detected text for consistency
        final originalLabelText = objects
            .expand((obj) => obj.labels)
            .map((l) => l.text)
            .firstWhere((text) => text.toLowerCase().trim() == label, orElse: () => label);
        sourceTranslatedLabels[label] = originalLabelText;
      }
    }
    await Future.wait(futures);
  }
}
