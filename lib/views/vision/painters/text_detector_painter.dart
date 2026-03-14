import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../models/tracked_text_block.dart';
import 'coordinates_translator.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
    this.trackedBlocks,
    this.absoluteImageSize,
    this.rotation,
    this.translatedBlocks,
  );

  final List<TrackedTextBlock> trackedBlocks;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final Map<String, String> translatedBlocks;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final Paint bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black45;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.lightGreenAccent.withValues(alpha: 0.5);

    // 1. Tính toán tất cả rects trước
    final List<_BlockEntry> entries = [];
    for (final block in trackedBlocks) {
      final rect = Rect.fromLTRB(
        translateX(
            block.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(
            block.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(
            block.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(
            block.boundingBox.bottom, rotation, size, absoluteImageSize),
      );
      entries.add(_BlockEntry(block, rect));
    }

    // 3. Vẽ các block
    for (final entry in entries) {
      final rect = entry.rect;
      final block = entry.block;

      final String id = block.id;
      final String translatedText = translatedBlocks[id] ?? "";
      final String displayText = translatedText.isNotEmpty ? translatedText : block.text;

      // Draw background with rounded corners
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rRect, bgPaint);
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
      
      tp.layout(maxWidth: rect.width > 4 ? rect.width - 4 : rect.width);
      
      // Center text in rect
      final offset = Offset(
        rect.left + (rect.width - tp.width) / 2,
        rect.top + (rect.height - tp.height) / 2,
      );
      
      tp.paint(canvas, offset);
    }

    canvas.restore();
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Helper class to pair a TextBlock with its translated Rect
class _BlockEntry {
  final TrackedTextBlock block;
  final Rect rect;
  _BlockEntry(this.block, this.rect);
}
