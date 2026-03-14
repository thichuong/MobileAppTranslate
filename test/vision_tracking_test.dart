import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_app_translate/utils/vision_results_processor.dart';

void main() {
  test('VisionResultsProcessor - Spatial Tracking (IoU)', () {
    final processor = VisionResultsProcessor();
    
    final block1 = TextBlock(
      text: "Hello",
      boundingBox: const Rect.fromLTWH(10, 10, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    final results1 = RecognizedText(text: "Hello", blocks: [block1]);
    final tracked1 = processor.smoothTextResults(results1);
    
    expect(tracked1.length, 1);
    final id1 = tracked1[0].id;
    
    // Move slightly (IoU should be high)
    final block2 = TextBlock(
      text: "Hello",
      boundingBox: const Rect.fromLTWH(12, 12, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    final results2 = RecognizedText(text: "Hello", blocks: [block2]);
    final tracked2 = processor.smoothTextResults(results2);
    
    expect(tracked2.length, 1);
    expect(tracked2[0].id, id1); // ID should be preserved
  });

  test('VisionResultsProcessor - Fuzzy Matching & Stabilization', () {
    final processor = VisionResultsProcessor();
    
    final block1 = TextBlock(
      text: "Hello",
      boundingBox: const Rect.fromLTWH(10, 10, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    final tracked1 = processor.smoothTextResults(RecognizedText(text: "Hello", blocks: [block1]));
    final id1 = tracked1[0].id;
    
    // OCR Jitter (Same position, but text changed slightly)
    final block2 = TextBlock(
      text: "He1lo", // Fuzzy match to "Hello"
      boundingBox: const Rect.fromLTWH(11, 11, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    final tracked2 = processor.smoothTextResults(RecognizedText(text: "He1lo", blocks: [block2]));
    
    expect(tracked2.length, 1);
    expect(tracked2[0].id, id1);
    expect(tracked2[0].text, "Hello"); // Text should be stabilized if similarity is high
  });

  test('VisionResultsProcessor - Decay and Ghosting', () async {
    final processor = VisionResultsProcessor();
    
    final block1 = TextBlock(
      text: "Ghost",
      boundingBox: const Rect.fromLTWH(10, 10, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    processor.smoothTextResults(RecognizedText(text: "Ghost", blocks: [block1]));
    
    // Next frame has no blocks
    final tracked2 = processor.smoothTextResults(RecognizedText(text: "", blocks: []));
    
    // Should still have 1 block due to ghosting
    expect(tracked2.length, 1);
    expect(tracked2[0].text, "Ghost");
    
    // Wait for decay duration
    await Future.delayed(const Duration(milliseconds: 800));
    
    final tracked3 = processor.smoothTextResults(RecognizedText(text: "", blocks: []));
    expect(tracked3.length, 0); // Should be removed now
  });
}
