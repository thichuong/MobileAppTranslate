import 'package:get/get.dart';
import '../controllers/camera_manager_controller.dart';
import '../controllers/vision_analyzer_controller.dart';
import '../controllers/vision_controller.dart';

class VisionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CameraManagerController());
    Get.lazyPut(() => VisionAnalyzerController());
    Get.lazyPut(() => VisionController());
  }
}
