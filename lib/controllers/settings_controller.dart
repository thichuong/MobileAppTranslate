import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vision_service.dart';

class SettingsController extends GetxController {
  static const String _modelKey = 'selected_efficientnet_model';
  
  final Rx<EfficientNetModel> selectedModel = EfficientNetModel.lite4.obs;
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
  }

  Future<void> setModel(EfficientNetModel model) async {
    selectedModel.value = model;
    await _prefs.setString(_modelKey, model.name);
    
    // Thông báo cho VisionService cập nhật model ngay lập tức nếu cần
    final visionService = Get.find<VisionService>();
    await visionService.switchModel(model);
  }
}
