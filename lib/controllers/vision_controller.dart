
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/camera_service.dart';
import '../services/vision_service.dart';

enum VisionMode { text, object }

class VisionController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final VisionService _visionService = Get.find<VisionService>();

  final Rx<VisionMode> mode = VisionMode.text.obs;
  final RxBool isBusy = false.obs;

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
    await _cameraService.initializeController();
    _cameraService.controller?.startImageStream(_processCameraImage);
    update();
  }

  Future<void> stopLiveFeed() async {
    await _cameraService.controller?.stopImageStream();
    await _cameraService.disposeController();
  }

  void toggleMode() {
    mode.value = mode.value == VisionMode.text
        ? VisionMode.object
        : VisionMode.text;

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
