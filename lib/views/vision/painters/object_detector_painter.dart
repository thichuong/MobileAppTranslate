import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
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
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.cyanAccent;

    for (final object in objects) {
      final rect = Rect.fromLTRB(
        translateX(object.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(object.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(object.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(
            object.boundingBox.bottom, rotation, size, absoluteImageSize),
      );

      canvas.drawRect(rect, paint);

      for (final label in object.labels) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text:
                '${label.text} (${(label.confidence * 100).toStringAsFixed(0)}%)',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black87,
            ),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(rect.left, rect.top - 20));
        break; // Show only the first label
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
