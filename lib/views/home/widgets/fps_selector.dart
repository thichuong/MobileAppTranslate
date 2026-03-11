import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FpsSelector extends StatelessWidget {
  final RxInt currentValue;
  final double min;
  final double max;
  final int divisions;
  final Function(double) onChanged;
  final String Function(double) label;

  const FpsSelector({
    super.key,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
}
