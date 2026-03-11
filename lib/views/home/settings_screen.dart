import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../services/vision_service.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Mô hình Nhận diện Vật thể'),
          const SizedBox(height: 12),
          _buildModelSelector(),
          const SizedBox(height: 24),
          _buildSectionHeader('Tốc độ Camera (FPS)'),
          const SizedBox(height: 12),
          _buildFpsSelector(
            currentValue: controller.cameraFps,
            min: 15,
            max: 60,
            divisions: 3,
            onChanged: (v) => controller.setCameraFps(v.toInt()),
            label: (v) => '${v.toInt()} FPS',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Tốc độ Xử lý AI (FPS)'),
          const SizedBox(height: 12),
          _buildFpsSelector(
            currentValue: controller.processingFps,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => controller.setProcessingFps(v.toInt()),
            label: (v) => '${v.toInt()} FPS',
          ),
          const SizedBox(height: 24),
          _buildInfoNote(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white54,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: EfficientNetModel.values.map((model) {
          final bool isLast = model == EfficientNetModel.lite4;
          return Obx(() {
            final bool isSelected = controller.selectedModel.value == model;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Get.theme.colorScheme.primary : Colors.white24,
                  ),
                  title: Text(
                    model.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: _buildModelBadge(model),
                  onTap: () => controller.setModel(model),
                ),
                if (!isLast)
                  Divider(
                    indent: 60,
                    endIndent: 20,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
              ],
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildModelBadge(EfficientNetModel model) {
    String size = '';
    switch (model) {
      case EfficientNetModel.lite0: size = '5.2 MB'; break;
      case EfficientNetModel.lite1: size = '6.1 MB'; break;
      case EfficientNetModel.lite2: size = '6.8 MB'; break;
      case EfficientNetModel.lite3: size = '9.2 MB'; break;
      case EfficientNetModel.lite4: size = '14.3 MB'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        size,
        style: const TextStyle(fontSize: 10, color: Colors.white38),
      ),
    );
  }

  Widget _buildFpsSelector({
    required RxInt currentValue,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String Function(double) label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Obx(() => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giá trị:',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    label(currentValue.value.toDouble()),
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: currentValue.value.toDouble(),
                min: min,
                max: max,
                divisions: divisions,
                activeColor: Get.theme.colorScheme.primary,
                inactiveColor: Colors.white10,
                onChanged: onChanged,
              ),
            ],
          )),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Get.theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Get.theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mô hình số cao hơn (như Lite4) cho độ chính xác tốt hơn nhưng tốn nhiều pin và tài nguyên hơn.',
              style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
