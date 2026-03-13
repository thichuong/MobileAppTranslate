import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../services/camera_service.dart';

class CameraManagerController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();

  final RxBool isInitialized = false.obs;
  final RxBool isStreamRunning = false.obs;

  CameraController? get controller => _cameraService.controller;
  List<CameraDescription> get cameras => _cameraService.cameras;

  Future<void> initialize() async {
    await _cameraService.initializeController();
    isInitialized.value = true;
  }

  Future<void> startImageStream(void Function(CameraImage image) onFrame) async {
    if (controller != null && !isStreamRunning.value) {
      await controller!.startImageStream(onFrame);
      isStreamRunning.value = true;
    }
  }

  Future<void> stopImageStream() async {
    if (controller != null && isStreamRunning.value) {
      if (controller!.value.isStreamingImages) {
        await controller!.stopImageStream();
      }
      isStreamRunning.value = false;
    }
  }

  Future<void> disposeController() async {
    await stopImageStream();
    // CameraService handles the actual controller disposal if needed
    isInitialized.value = false;
  }

  @override
  void onClose() {
    stopImageStream();
    super.onClose();
  }
}
