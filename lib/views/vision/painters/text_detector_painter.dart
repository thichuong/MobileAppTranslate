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
    canvas.save();

    final Paint bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black45;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.lightGreenAccent.withValues(alpha: 0.5);

    // 1. Tính toán tất cả rects trước để dedup
    final List<_BlockEntry> entries = [];
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
      entries.add(_BlockEntry(textBlock, rect));
    }

    // 2. Dedup: loại bỏ các box trùng lặp (IoU > 0.5)
    final List<_BlockEntry> dedupedEntries = [];
    for (final entry in entries) {
      bool isDuplicate = false;
      for (final existing in dedupedEntries) {
        if (_iou(entry.rect, existing.rect) > 0.5) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        dedupedEntries.add(entry);
      }
    }

    // 3. Vẽ các block đã dedup
    for (final entry in dedupedEntries) {
      final rect = entry.rect;
      final textBlock = entry.block;

      // Normalize key for translation lookup
      final String normalizedKey = textBlock.text.trim()
          .replaceAll(RegExp(r'[ \t]+'), ' ')
          .toLowerCase();
      
      final String translatedText = translatedBlocks[normalizedKey] ?? "";
      final String displayText = translatedText.isNotEmpty ? translatedText : textBlock.text;

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

  /// Tính Intersection over Union (IoU) của 2 rect
  double _iou(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.isEmpty) return 0.0;
    final intersectionArea = intersection.width * intersection.height;
    final unionArea = a.width * a.height + b.width * b.height - intersectionArea;
    if (unionArea <= 0) return 0.0;
    return intersectionArea / unionArea;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Helper class to pair a TextBlock with its translated Rect
class _BlockEntry {
  final TextBlock block;
  final Rect rect;
  _BlockEntry(this.block, this.rect);
}
