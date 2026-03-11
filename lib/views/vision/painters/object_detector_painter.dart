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
    this.sourceTranslatedLabels,
  );

  final List<DetectedObject> objects;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final Map<String, String> translatedLabels;
  final Map<String, String> sourceTranslatedLabels;

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
        final String sourceTranslated = sourceTranslatedLabels[normalizedLabel] ?? label.text;
        
        final String confidenceText = '${(label.confidence * 100).toStringAsFixed(0)}%';

        final TextSpan span = TextSpan(
          children: [
            TextSpan(
              text: "$sourceTranslated ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: confidenceText,
              style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (translated.isNotEmpty) ...[
              TextSpan(
                text: "\n$translated",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
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
          rect.top + yOffset,
          tp.width + 12,
          tp.height + 8,
        );
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
          labelBgPaint,
        );

        tp.paint(canvas, Offset(rect.left + 6, rect.top + 4 + yOffset));
        yOffset += tp.height + 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
