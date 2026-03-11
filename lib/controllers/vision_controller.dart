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
import 'settings_controller.dart';

enum VisionMode { text, object }

class VisionController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final VisionService _visionService = Get.find<VisionService>();

  final Rx<VisionMode> mode = VisionMode.text.obs;
  final RxBool isBusy = false.obs;
  final RxBool isLive = true.obs;
  final Rx<String?> imagePath = Rx<String?>(null);
  final ImagePicker _picker = ImagePicker();

  // Results
  final Rx<RecognizedText?> recognizedText = Rx<RecognizedText?>(null);
  final RxList<DetectedObject> detectedObjects = <DetectedObject>[].obs;

  // Camera metadata for painter
  final Rx<Size?> _imageSize = Rx<Size?>(null);
  Size? get imageSize => _imageSize.value;

  final Rx<InputImageRotation?> _imageRotation = Rx<InputImageRotation?>(null);
  InputImageRotation? get imageRotation => _imageRotation.value;

  @override
  void onInit() {
    super.onInit();
    startLiveFeed();
  }

  Future<void> startLiveFeed() async {
    isLive.value = true;
    final settings = Get.find<SettingsController>();
    await _visionService.initCustomDetector(
        model: settings.selectedModel.value);
    await _cameraService.initializeController();
    _cameraService.controller?.startImageStream(_processCameraImage);
    update();
  }

  Future<void> stopLiveFeed() async {
    isLive.value = false;
    if (_cameraService.controller?.value.isStreamingImages ?? false) {
      await _cameraService.controller?.stopImageStream();
    }
  }

  void toggleMode() {
    mode.value = mode.value == VisionMode.text
        ? VisionMode.object
        : VisionMode.text;

    // Clear results on mode switch
    recognizedText.value = null;
    detectedObjects.clear();

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
        // Collect labels from detected objects
        final labels = detectedObjects
            .expand((obj) => obj.labels)
            .where((label) => label.confidence > 0.5)
            .map((label) => label.text)
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

  void _processCameraImage(CameraImage image) async {
    if (isBusy.value) return;
    isBusy.value = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      isBusy.value = false;
      return;
    }

    _imageSize.value = Size(image.width.toDouble(), image.height.toDouble());
    _imageRotation.value = inputImage.metadata?.rotation;

    try {
      if (mode.value == VisionMode.text) {
        recognizedText.value = await _visionService.recognizeText(inputImage);
      } else {
        detectedObjects.value = await _visionService.detectObjects(inputImage);
      }
    } catch (e) {
      debugPrint("Vision error: $e");
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> captureImage() async {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) return;

    try {
      isBusy.value = true;
      final XFile file = await _cameraService.controller!.takePicture();
      imagePath.value = file.path;
      await stopLiveFeed();
      await _processStaticImage(file.path);
    } catch (e) {
      debugPrint("Capture error: $e");
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        isBusy.value = true;
        imagePath.value = image.path;
        await stopLiveFeed();
        await _processStaticImage(image.path);
      }
    } catch (e) {
      debugPrint("Picker error: $e");
    } finally {
      isBusy.value = false;
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
        recognizedText.value = await _visionService.recognizeText(inputImage);
      } else {
        detectedObjects.value = await _visionService.detectObjects(inputImage);
      }
    } catch (e) {
      debugPrint("Static processing error: $e");
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraService.controller == null) return null;

    final camera = _cameraService.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameraService.cameras.first,
    );

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (GetPlatform.isAndroid) {
      var rotationCompensation =
          _cameraService.controller!.description.sensorOrientation;
      if (_cameraService.controller!.description.lensDirection ==
          CameraLensDirection.front) {
        rotationCompensation = (rotationCompensation + 0) % 360;
      } else {
        rotationCompensation = (rotationCompensation - 0 + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else if (GetPlatform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void onClose() {
    stopLiveFeed();
    super.onClose();
  }
}
