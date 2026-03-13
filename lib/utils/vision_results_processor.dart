import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VisionResultsProcessor {
  // Smoothing and temporal tracking
  final Map<String, Rect> _smoothedRects = {};
  final Map<String, DateTime> _lastSeenRects = {};
  final Map<String, TextBlock> _cachedBlocks = {}; // Store full blocks for ghosting
  static const Duration _rectDecayDuration = Duration(milliseconds: 500);
  static const double _smoothingFactor = 0.4; // Low value = more smoothing

  RecognizedText smoothTextResults(RecognizedText results) {
    final now = DateTime.now();
    final List<TextBlock> smoothedBlocks = [];
    final Set<String> currentKeys = {};

    // 1. Update smoothing for blocks in current frame
    for (final block in results.blocks) {
      final key = normalizeText(block.text);
      if (key.isEmpty) continue;
      currentKeys.add(key);

      if (_smoothedRects.containsKey(key)) {
        // Interpolate rect
        final oldRect = _smoothedRects[key]!;
        final newRect = block.boundingBox;
        _smoothedRects[key] = Rect.fromLTRB(
          _lerp(oldRect.left, newRect.left, _smoothingFactor),
          _lerp(oldRect.top, newRect.top, _smoothingFactor),
          _lerp(oldRect.right, newRect.right, _smoothingFactor),
          _lerp(oldRect.bottom, newRect.bottom, _smoothingFactor),
        );
      } else {
        _smoothedRects[key] = block.boundingBox;
      }
      _lastSeenRects[key] = now;
      _cachedBlocks[key] = block;

      // Add block with smoothed rect to result
      smoothedBlocks.add(TextBlock(
        text: block.text,
        lines: block.lines,
        boundingBox: _smoothedRects[key]!,
        recognizedLanguages: block.recognizedLanguages,
        cornerPoints: block.cornerPoints,
      ));
    }

    // 2. Add ghost blocks (only for keys NOT in current frame) to prevent flicker
    _lastSeenRects.forEach((key, lastSeen) {
      if (currentKeys.contains(key)) return; // Already added in step 1
      if (now.difference(lastSeen) > _rectDecayDuration) return; // Too old

      final cachedBlock = _cachedBlocks[key];
      if (cachedBlock == null) return;

      smoothedBlocks.add(TextBlock(
        text: cachedBlock.text,
        lines: cachedBlock.lines,
        boundingBox: _smoothedRects[key]!,
        recognizedLanguages: cachedBlock.recognizedLanguages,
        cornerPoints: cachedBlock.cornerPoints,
      ));
    });

    // 3. Cleanup old keys
    final List<String> keysToRemove = [];
    _lastSeenRects.forEach((key, lastSeen) {
      if (now.difference(lastSeen) > _rectDecayDuration) {
        keysToRemove.add(key);
      }
    });
    for (final key in keysToRemove) {
      _lastSeenRects.remove(key);
      _smoothedRects.remove(key);
      _cachedBlocks.remove(key);
    }

    return RecognizedText(text: results.text, blocks: smoothedBlocks);
  }

  void clearSmoothingCaches() {
    _smoothedRects.clear();
    _lastSeenRects.clear();
    _cachedBlocks.clear();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  String normalizeText(String text) {
    return text.trim()
        .replaceAll(RegExp(r'[ \t]+'), ' ') // Normalize spaces
        .toLowerCase();
  }
}
