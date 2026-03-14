import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import './widgets/model_selector.dart';
import './widgets/fps_selector.dart';
import './widgets/info_note.dart';

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
          ModelSelector(controller: controller),
          const SizedBox(height: 16),
          const InfoNote(
            text: 'Mô hình số cao hơn (như Lite4) cho độ chính xác tốt hơn nhưng tốn nhiều pin và tài nguyên hơn.',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Tốc độ Camera (FPS)'),
          const SizedBox(height: 12),
          FpsSelector(
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
          FpsSelector(
            currentValue: controller.processingFps,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => controller.setProcessingFps(v.toInt()),
            label: (v) => '${v.toInt()} FPS',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Thời gian chờ OCR (ms)'),
          const SizedBox(height: 12),
          FpsSelector(
            currentValue: controller.ocrCooldown,
            min: 500,
            max: 5000,
            divisions: 9,
            onChanged: (v) => controller.setOcrCooldown(v.toInt()),
            label: (v) => '${v.toInt()} ms',
          ),
          const SizedBox(height: 16),
          const InfoNote(
            text: 'Thời gian chờ lâu giúp giảm nháy hình ảnh khi text bị jitter, nhưng phản hồi chậm hơn khi text thực sự thay đổi.',
          ),
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
}
