import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/camera_service.dart';
import '../services/vision_service.dart';

enum DetectionMode { text, object }

class VisionController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final VisionService _visionService = Get.find<VisionService>();

  final Rx<DetectionMode> mode = DetectionMode.text.obs;
  final RxBool isBusy = false.obs;

  // Results
  final Rx<RecognizedText?> recognizedText = Rx<RecognizedText?>(null);
  final RxList<DetectedObject> detectedObjects = <DetectedObject>[].obs;

  // Camera metadata for painter
  Size? imageSize;
  InputImageRotation? imageRotation;

  @override
  void onInit() {
    super.onInit();
    startLiveFeed();
  }

  Future<void> startLiveFeed() async {
    await _cameraService.initializeController();
    _cameraService.controller?.startImageStream(_processCameraImage);
    update();
  }

  Future<void> stopLiveFeed() async {
    await _cameraService.controller?.stopImageStream();
    await _cameraService.disposeController();
  }

  void toggleMode() {
    mode.value = mode.value == DetectionMode.text
        ? DetectionMode.object
        : DetectionMode.text;

    // Clear results on mode switch
    recognizedText.value = null;
    detectedObjects.clear();
  }

  void _processCameraImage(CameraImage image) async {
    if (isBusy.value) return;
    isBusy.value = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      isBusy.value = false;
      return;
    }

    imageSize = Size(image.width.toDouble(), image.height.toDouble());
    imageRotation = inputImage.metadata?.rotation;

    try {
      if (mode.value == DetectionMode.text) {
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
    if (format == null ||
        (GetPlatform.isAndroid && format != InputImageFormat.nv21) ||
        (GetPlatform.isIOS && format != InputImageFormat.bgra8888)) {
      // Potentially fallback for different formats if needed
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat
            .bgra8888, // Assuming bgra8888 as per camera_service.dart config
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
