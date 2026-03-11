import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vision_controller.dart';
import '../../../controllers/translate_controller.dart';
import '../../../services/camera_service.dart';
import 'painters/text_detector_painter.dart';
import 'painters/object_detector_painter.dart';

class VisionDetectorScreen extends StatelessWidget {
  const VisionDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    return Obx(() {
      if (!controller.isLive.value && controller.imagePath.value != null) {
        // Dùng BoxFit.cover để cùng kích thước với camera preview
        return SizedBox.expand(
          child: Image.file(
            File(controller.imagePath.value!),
            fit: BoxFit.cover,
          ),
        );
      }

      final cameraService = Get.find<CameraService>();
      if (cameraService.controller == null ||
          !cameraService.controller!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cameraService.controller!.value.previewSize!.height,
            height: cameraService.controller!.value.previewSize!.width,
            child: CameraPreview(cameraService.controller!),
          ),
        ),
      );
    });
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
            controller.translatedTextBlocks,
          );
        }
      } else {
        if (controller.detectedObjects.isNotEmpty) {
          painter = ObjectDetectorPainter(
            controller.detectedObjects,
            controller.imageSize!,
            controller.imageRotation!,
            controller.translatedLabels,
            controller.sourceTranslatedLabels,
          );
        }
      }

      if (painter == null) return const SizedBox.shrink();

      // Luôn vẽ full screen — kết quả detection từ live mode
      // và ảnh tĩnh đều dùng cùng kích thước (BoxFit.cover)
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
                _buildIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Get.back(),
                ),
                Expanded(
                  child: Center(
                    child: Obx(() {
                      final tc = Get.find<TranslateController>();
                      final source = tc.sourceLanguage.value.toString().split('.').last.toUpperCase();
                      final target = tc.targetLanguage.value.toString().split('.').last.toUpperCase();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$source → $target",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 48), // Placeholder
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
                const SizedBox(height: 32),
                // Main Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      icon: Icons.photo_library_outlined,
                      onTap: () => controller.pickImage(),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => controller.captureImage(),
                          child: Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Obx(() => controller.isActionBusy.value
                            ? const SizedBox(
                                height: 72,
                                width: 72,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 4,
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                    Obx(() => !controller.isLive.value
                        ? _buildIconButton(
                            icon: Icons.refresh_rounded,
                            onTap: () => controller.startLiveFeed(),
                          )
                        : const SizedBox(width: 48)),
                  ],
                ),
              ],
            ),
          ),

          // Translate Button
          Obx(() {
            final hasResults = (controller.recognizedText.value != null &&
                    controller.recognizedText.value!.text.isNotEmpty) ||
                (controller.detectedObjects.isNotEmpty);

            if (!hasResults || controller.isLive.value) {
              return const SizedBox.shrink();
            }

            return Positioned(
              bottom: 156,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => controller.sendToTranslate(),
                  icon: const Icon(Icons.translate_rounded),
                  label: const Text("Translate Results"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return CircleAvatar(
      backgroundColor: Colors.black54,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
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
