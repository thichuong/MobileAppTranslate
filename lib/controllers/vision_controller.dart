import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/translate_controller.dart';
import '../services/vision_service.dart';
import 'camera_manager_controller.dart';
import 'vision_analyzer_controller.dart' show VisionAnalyzerController, VisionMode;

class VisionController extends GetxController {
  final CameraManagerController _cameraManager = Get.find<CameraManagerController>();
  final VisionAnalyzerController _analyzer = Get.find<VisionAnalyzerController>();
  
  // Expose state from sub-controllers
  Rx<VisionMode> get mode => _analyzer.mode;
  Rx<RecognizedText?> get recognizedText => _analyzer.recognizedText;
  RxList<DetectedObject> get detectedObjects => _analyzer.detectedObjects;
  RxMap<String, String> get translatedTextBlocks => _analyzer.translatedTextBlocks;
  RxMap<String, String> get translatedLabels => _analyzer.translatedLabels;
  RxMap<String, String> get sourceTranslatedLabels => _analyzer.sourceTranslatedLabels;
  
  Size? get imageSize => _analyzer.imageSize.value;
  InputImageRotation? get imageRotation => _analyzer.imageRotation.value;
  TranslateLanguage get sourceLanguage => Get.find<TranslateController>().sourceLanguage.value;

  final RxBool isActionBusy = false.obs;
  final RxBool isLive = true.obs;
  final Rx<String?> imagePath = Rx<String?>(null);
  
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    startLiveFeed();
  }

  Future<void> startLiveFeed() async {
    isLive.value = true;
    imagePath.value = null;
    await _cameraManager.initialize();
    await _cameraManager.startImageStream(_analyzer.onCameraFrame);
    update();
  }

  Future<void> stopLiveFeed({bool cleanup = false}) async {
    isLive.value = false;
    await _cameraManager.stopImageStream();
  }

  void toggleMode() {
    _analyzer.mode.value = _analyzer.mode.value == VisionMode.text
        ? VisionMode.object
        : VisionMode.text;

    // Reset results on mode switch
    _analyzer.recognizedText.value = null;
    _analyzer.detectedObjects.clear();

    if (!isLive.value && imagePath.value != null) {
      _processStaticImage(imagePath.value!);
    }
  }

  void sendToTranslate() {
    String textToSend = "";

    if (_analyzer.mode.value == VisionMode.text) {
      if (_analyzer.recognizedText.value != null) {
        textToSend = _analyzer.recognizedText.value!.text;
      }
    } else {
      if (_analyzer.detectedObjects.isNotEmpty) {
        final isSourceEng = sourceLanguage == TranslateLanguage.english;
        final labels = _analyzer.detectedObjects
            .expand((obj) => obj.labels)
            .where((label) => label.confidence > 0.5)
            .map((label) {
              final normalized = label.text.toLowerCase().trim();
              if (isSourceEng) return label.text;
              return _analyzer.sourceTranslatedLabels[normalized] ?? label.text;
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

    Get.back();
  }

  Future<void> captureImage() async {
    if (_cameraManager.controller == null || !_cameraManager.controller!.value.isInitialized) return;

    try {
      isActionBusy.value = true;
      final XFile file = await _cameraManager.controller!.takePicture();
      imagePath.value = file.path;
      await stopLiveFeed();
    } catch (e) {
      Get.log("Capture error: $e");
    } finally {
      isActionBusy.value = false;
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
      Get.log("Picker error: $e");
    } finally {
      isActionBusy.value = false;
    }
  }

  Future<void> _processStaticImage(String path) async {
    // Basic static image processing - delegates to services/analyzer if needed
    // In a full implementation, analyzer would have a _processStaticImage method too
    final inputImage = InputImage.fromFilePath(path);
    final bytes = await File(path).readAsBytes();
    final Codec codec = await instantiateImageCodec(bytes);
    final FrameInfo fi = await codec.getNextFrame();
    
    _analyzer.imageSize.value = Size(fi.image.width.toDouble(), fi.image.height.toDouble());
    _analyzer.imageRotation.value = InputImageRotation.rotation0deg;

    final visionService = Get.find<VisionService>();
    if (_analyzer.mode.value == VisionMode.text) {
      final results = await visionService.recognizeTextSingle(inputImage);
      _analyzer.recognizedText.value = results;
    } else {
      final results = await visionService.detectObjectsSingle(inputImage);
      _analyzer.detectedObjects.assignAll(results);
    }
  }

  @override
  void onClose() {
    stopLiveFeed();
    super.onClose();
  }
}
