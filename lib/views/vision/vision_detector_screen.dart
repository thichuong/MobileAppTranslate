import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vision_controller.dart';
import '../../../services/camera_service.dart';
import 'painters/text_detector_painter.dart';
import 'painters/object_detector_painter.dart';

class VisionDetectorScreen extends StatelessWidget {
  const VisionDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We instantiate the controller here to manage its lifecycle via GetX
    return GetBuilder<VisionController>(
      init: VisionController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Preview
              _buildCameraPreview(controller),

              // 2. Painting Layer
              _buildCanvasLayer(controller),

              // 3. UI Controls
              _buildControls(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraPreview(VisionController controller) {
    final cameraService = Get.find<CameraService>();
    if (cameraService.controller == null ||
        !cameraService.controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(cameraService.controller!);
  }

  Widget _buildCanvasLayer(VisionController controller) {
    return Obx(() {
      if (controller.imageSize == null || controller.imageRotation == null) {
        return const SizedBox.shrink();
      }

      CustomPainter? painter;
      if (controller.mode.value == VisionMode.text) {
        if (controller.recognizedText.value != null) {
          painter = TextDetectorPainter(
            controller.recognizedText.value!,
            controller.imageSize!,
            controller.imageRotation!,
          );
        }
      } else {
        if (controller.detectedObjects.isNotEmpty) {
          painter = ObjectDetectorPainter(
            controller.detectedObjects,
            controller.imageSize!,
            controller.imageRotation!,
          );
        }
      }

      if (painter == null) return const SizedBox.shrink();

      return CustomPaint(painter: painter);
    });
  }

  Widget _buildControls(BuildContext context, VisionController controller) {
    return SafeArea(
      child: Stack(
        children: [
          // Top Bar
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.mode.value == VisionMode.text
                            ? "OCR Mode"
                            : "Object Mode",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )),
                const SizedBox(width: 48), // Placeholder to balance back button
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Mode Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeBtn(
                              "Text",
                              controller.mode.value == VisionMode.text,
                              () => controller.mode.value = VisionMode.text),
                          _buildModeBtn(
                              "Objects",
                              controller.mode.value == VisionMode.object,
                              () =>
                                  controller.mode.value = VisionMode.object),
                        ],
                      )),
                ),
                const SizedBox(height: 24),
                // Status info
                Obx(() => controller.isBusy.value
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.check_circle_outline,
                        color: Colors.greenAccent, size: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
