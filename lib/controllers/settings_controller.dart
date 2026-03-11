import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vision_service.dart';

class SettingsController extends GetxController {
  static const String _modelKey = 'selected_efficientnet_model';
  static const String _cameraFpsKey = 'camera_fps';
  static const String _processingFpsKey = 'processing_fps';
  
  final Rx<EfficientNetModel> selectedModel = EfficientNetModel.lite4.obs;
  final RxInt cameraFps = 60.obs;
  final RxInt processingFps = 5.obs;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    final savedModel = _prefs.getString(_modelKey);
    if (savedModel != null) {
      selectedModel.value = EfficientNetModel.fromString(savedModel);
    }

    cameraFps.value = _prefs.getInt(_cameraFpsKey) ?? 60;
    processingFps.value = _prefs.getInt(_processingFpsKey) ?? 5;
  }

  Future<void> setModel(EfficientNetModel model) async {
    selectedModel.value = model;
    await _prefs.setString(_modelKey, model.name);
    
    final visionService = Get.find<VisionService>();
    await visionService.switchModel(model);
  }

  Future<void> setCameraFps(int fps) async {
    cameraFps.value = fps;
    await _prefs.setInt(_cameraFpsKey, fps);
  }

  Future<void> setProcessingFps(int fps) async {
    processingFps.value = fps;
    await _prefs.setInt(_processingFpsKey, fps);
  }
}
