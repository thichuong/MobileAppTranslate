import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'coordinates_translator.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
    this.recognizedText,
    this.absoluteImageSize,
    this.rotation,
    this.translatedBlocks,
  );

  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final Map<String, String> translatedBlocks;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black45;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.lightGreenAccent.withOpacity(0.5);

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

      // Normalize key for translation lookup
      final String normalizedKey = textBlock.text.trim()
          .replaceAll(RegExp(r'[ \t]+'), ' ')
          .toLowerCase();
      
      final String translatedText = translatedBlocks[normalizedKey] ?? "";
      final String displayText = translatedText.isNotEmpty ? translatedText : textBlock.text;

      // Draw background with rounded corners
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rRect, paint);
      canvas.drawRRect(rRect, borderPaint);

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: displayText,
          style: TextStyle(
            color: translatedText.isNotEmpty ? Colors.white : Colors.lightGreenAccent,
            fontSize: 12,
            fontWeight: translatedText.isNotEmpty ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: (rect.height / 14).floor().clamp(1, 10),
        ellipsis: '...',
      );
      
      tp.layout(maxWidth: rect.width - 4);
      
      // Center text in rect
      final offset = Offset(
        rect.left + (rect.width - tp.width) / 2,
        rect.top + (rect.height - tp.height) / 2,
      );
      
      tp.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
