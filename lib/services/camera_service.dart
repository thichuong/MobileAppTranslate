import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraService extends GetxService {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool isInitialized = false;

  Future<void> initCameras() async {
    cameras = await availableCameras();
  }

  Future<void> initializeController({
    CameraDescription? cameraDescription,
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    if (cameras.isEmpty) await initCameras();

    final selectedCamera = cameraDescription ??
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

    controller = CameraController(
      selectedCamera,
      resolution,
      enableAudio: false,
      imageFormatGroup: GetPlatform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller?.initialize();
    
    // Note: To set specific FPS (like 60FPS), hardware must support it.
    // Most modern devices default to 30/60 depending on light.
    // In advanced implementations, one would use fpsRange if available.

    isInitialized = true;
  }

  Future<void> disposeController() async {
    await controller?.dispose();
    controller = null;
    isInitialized = false;
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}
