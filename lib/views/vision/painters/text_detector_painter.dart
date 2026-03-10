import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'coordinates_translator.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
    this.recognizedText,
    this.absoluteImageSize,
    this.rotation,
  );

  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.lightGreenAccent;

    for (final textBlock in recognizedText.blocks) {
      final rect = Rect.fromLTRB(
        translateX(
            textBlock.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(
            textBlock.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(
            textBlock.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(
            textBlock.boundingBox.bottom, rotation, size, absoluteImageSize),
      );

      canvas.drawRect(rect, paint);

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: textBlock.text,
          style: const TextStyle(
            color: Colors.lightGreenAccent,
            fontSize: 12,
            backgroundColor: Colors.black54,
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(rect.left, rect.top));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
