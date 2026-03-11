import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../../../services/vision_service.dart';
import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
    this.objects,
    this.absoluteImageSize,
    this.rotation,
  );

  final List<DetectedObject> objects;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.cyanAccent;

    final Paint bgPaint = Paint()..color = Colors.black87;

    for (final object in objects) {
      final rect = Rect.fromLTRB(
        translateX(object.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(object.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(object.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(
            object.boundingBox.bottom, rotation, size, absoluteImageSize),
      );

      canvas.drawRect(rect, boxPaint);

      // Lọc labels theo confidence threshold và giới hạn số lượng
      final filteredLabels = object.labels
          .where((l) => l.confidence >= VisionService.confidenceThreshold)
          .take(VisionService.maxLabelsPerObject)
          .toList();

      // Vẽ từng label phía trên bounding box
      double yOffset = 0;
      for (final label in filteredLabels) {
        final text =
            '${label.text} (${(label.confidence * 100).toStringAsFixed(0)}%)';
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();

        // Vẽ nền đen cho text
        final textRect = Rect.fromLTWH(
          rect.left,
          rect.top - 20 - yOffset,
          tp.width + 8,
          tp.height + 4,
        );
        canvas.drawRect(textRect, bgPaint);

        tp.paint(canvas, Offset(rect.left + 4, rect.top - 18 - yOffset));
        yOffset += tp.height + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
