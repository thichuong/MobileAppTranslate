import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_app_translate/utils/vision_results_processor.dart';

void main() {
  test('VisionResultsProcessor - Dynamic OCR Cooldown', () async {
    final processor = VisionResultsProcessor();
    
    // Default cooldown is 1500ms
    final block1 = TextBlock(
      text: "Hello",
      boundingBox: const Rect.fromLTWH(10, 10, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    processor.smoothTextResults(RecognizedText(text: "Hello", blocks: [block1]));
    
    // Frame within 1500ms with jittery text (should not update)
    final block2 = TextBlock(
      text: "He1lo",
      boundingBox: const Rect.fromLTWH(11, 11, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );
    
    var results = processor.smoothTextResults(RecognizedText(text: "He1lo", blocks: [block2]));
    expect(results[0].text, "Hello"); // Still "Hello" due to cooldown OR similarity
    
    // Change cooldown to 100ms
    processor.setOcrCooldown(100);
    await Future.delayed(const Duration(milliseconds: 150));
    
    // New frame with very different text (should update now that cooldown passed)
    final block3 = TextBlock(
      text: "World",
      boundingBox: const Rect.fromLTWH(11, 11, 100, 50),
      lines: const [],
      recognizedLanguages: const [],
      cornerPoints: const [],
    );

    results = processor.smoothTextResults(RecognizedText(text: "World", blocks: [block3]));
    expect(results[0].text, "World"); // Updated because cooldown passed and similarity is low
  });
}
