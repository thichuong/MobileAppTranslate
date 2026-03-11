import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../../../services/vision_service.dart';
import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
    this.objects,
    this.absoluteImageSize,
    this.rotation,
    this.translatedLabels,
  );

  final List<DetectedObject> objects;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final Map<String, String> translatedLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.cyanAccent;

    final Paint labelBgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final object in objects) {
      final rect = Rect.fromLTRB(
        translateX(object.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(object.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(object.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(
            object.boundingBox.bottom, rotation, size, absoluteImageSize),
      );

      // Draw bounding box with slight glow effect simulated by stroke
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        boxPaint,
      );

      final filteredLabels = object.labels
          .where((l) => l.confidence >= VisionService.confidenceThreshold)
          .take(VisionService.maxLabelsPerObject)
          .toList();

      double yOffset = 0;
      for (final label in filteredLabels) {
        final String normalizedLabel = label.text.toLowerCase().trim();
        final String translated = translatedLabels[normalizedLabel] ?? "";
        
        final String displayText = translated.isNotEmpty
            ? '${label.text} ($translated)'
            : label.text;
        final String confidenceText = '${(label.confidence * 100).toStringAsFixed(0)}%';

        final TextSpan span = TextSpan(
          children: [
            TextSpan(
              text: "$displayText ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: confidenceText,
              style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );

        final TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();

        final labelRect = Rect.fromLTWH(
          rect.left,
          rect.top - tp.height - 8 - yOffset,
          tp.width + 12,
          tp.height + 6,
        );
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
          labelBgPaint,
        );

        tp.paint(canvas, Offset(rect.left + 6, rect.top - tp.height - 5 - yOffset));
        yOffset += tp.height + 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
