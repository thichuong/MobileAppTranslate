import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:edit_distance/edit_distance.dart';
import '../models/tracked_text_block.dart';

class VisionResultsProcessor {
  // Tracking state
  final Map<String, TrackedTextBlock> _trackedBlocks = {};
  int _nextId = 0;

  // Smoothing parameters
  static const double _smoothingFactor = 0.35; // Lower = smoother but slower
  static const Duration _rectDecayDuration = Duration(milliseconds: 700);
  
  // Matching thresholds
  static const double _iouThreshold = 0.6; // Increased for tighter spatial tracking
  Duration _ocrCooldown = const Duration(milliseconds: 1500); // OCR Freeze duration

  void setOcrCooldown(int ms) {
    _ocrCooldown = Duration(milliseconds: ms);
  }

  final Levenshtein _levenshtein = Levenshtein();

  List<TrackedTextBlock> smoothTextResults(RecognizedText results) {
    final now = DateTime.now();
    final List<TrackedTextBlock> currentFrameTracked = [];
    final List<TextBlock> incomingBlocks = results.blocks;

    // 1. Match incoming blocks to tracked blocks using IoU
    final Set<int> matchedIncomingIndices = {};
    final Set<String> matchedTrackedIds = {};

    for (int i = 0; i < incomingBlocks.length; i++) {
      final incoming = incomingBlocks[i];
      String? bestMatchId;
      double bestScore = -1.0;

      _trackedBlocks.forEach((id, tracked) {
        if (matchedTrackedIds.contains(id)) return;

        final iou = _calculateIoU(incoming.boundingBox, tracked.boundingBox);
        double score = iou;

        // Spatial Match is primary
        if (score > _iouThreshold && score > bestScore) {
          bestScore = score;
          bestMatchId = id;
        }
      });

      if (bestMatchId != null) {
        final tracked = _trackedBlocks[bestMatchId!]!;
        final updatedRect = _lerpRect(tracked.boundingBox, incoming.boundingBox, _smoothingFactor);
        
        // OCR Cooldown Mechanism:
        // If IoU is strong (> 0.6) and we are within cooldown, KEEP the old text.
        // This avoids flickering translation keys when OCR returns jittery text (e.g. "Hello" -> "He1lo").
        final bool isWithinCooldown = now.difference(tracked.lastOcrTime) < _ocrCooldown;
        
        String stabilizedText = tracked.text;
        DateTime nextOcrTime = tracked.lastOcrTime;

        if (!isWithinCooldown) {
          // Cooldown passed, check if text actually changed significantly
          final similarity = _calculateTextSimilarity(incoming.text, tracked.text);
          if (similarity < 0.8) { // Text changed enough to update
             stabilizedText = incoming.text;
             nextOcrTime = now;
          }
        }

        final updatedTracked = tracked.copyWith(
          boundingBox: updatedRect,
          text: stabilizedText,
          lines: incoming.lines,
          lastSeen: now,
          lastOcrTime: nextOcrTime,
        );
        
        _trackedBlocks[bestMatchId!] = updatedTracked;
        currentFrameTracked.add(updatedTracked);
        matchedIncomingIndices.add(i);
        matchedTrackedIds.add(bestMatchId!);
      }
    }

    // 2. Add new blocks for unmatched ones
    for (int i = 0; i < incomingBlocks.length; i++) {
      if (matchedIncomingIndices.contains(i)) continue;
      
      final incoming = incomingBlocks[i];
      final id = "text_${_nextId++}";
      final newTracked = TrackedTextBlock(
        id: id,
        boundingBox: incoming.boundingBox,
        text: incoming.text,
        lines: incoming.lines,
        recognizedLanguages: incoming.recognizedLanguages,
        cornerPoints: incoming.cornerPoints,
        lastSeen: now,
        lastOcrTime: now,
      );
      _trackedBlocks[id] = newTracked;
      currentFrameTracked.add(newTracked);
    }

    // 3. Keep "ghost" blocks for a short duration to prevent flickers
    final List<TrackedTextBlock> resultsList = List.from(currentFrameTracked);
    
    _trackedBlocks.removeWhere((id, tracked) {
      final isGhost = !matchedTrackedIds.contains(id);
      final isTooOld = now.difference(tracked.lastSeen) > _rectDecayDuration;
      
      if (isGhost && !isTooOld && !currentFrameTracked.any((t) => t.id == id)) {
        resultsList.add(tracked);
        return false;
      }
      return isTooOld;
    });

    return resultsList;
  }

  double _calculateIoU(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.width <= 0 || intersection.height <= 0) return 0.0;
    
    final intersectionArea = intersection.width * intersection.height;
    final unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea;
    return intersectionArea / unionArea;
  }

  double _calculateTextSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    final distance = _levenshtein.distance(s1.toLowerCase(), s2.toLowerCase());
    final maxLength = max(s1.length, s2.length);
    return 1.0 - (distance / maxLength);
  }

  Rect _lerpRect(Rect a, Rect b, double t) {
    return Rect.fromLTRB(
      _lerp(a.left, b.left, t),
      _lerp(a.top, b.top, t),
      _lerp(a.right, b.right, t),
      _lerp(a.bottom, b.bottom, t),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void clearSmoothingCaches() {
    _trackedBlocks.clear();
    _nextId = 0;
  }
}
