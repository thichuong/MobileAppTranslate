import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../../../services/vision_service.dart';

class ModelSelector extends StatelessWidget {
  final SettingsController controller;

  const ModelSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
}
