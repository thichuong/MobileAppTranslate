import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoNote extends StatelessWidget {
  final String text;

  const InfoNote({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
