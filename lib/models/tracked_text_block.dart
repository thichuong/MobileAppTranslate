import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TrackedTextBlock {
  final String id;
  final Rect boundingBox;
  final String text;
  final List<TextLine> lines;
  final List<String> recognizedLanguages;
  final List<Point<int>> cornerPoints;
  final DateTime lastSeen;
  final DateTime lastOcrTime; // Added for cooldown management

  TrackedTextBlock({
    required this.id,
    required this.boundingBox,
    required this.text,
    required this.lines,
    required this.recognizedLanguages,
    required this.cornerPoints,
    required this.lastSeen,
    required this.lastOcrTime,
  });

  TrackedTextBlock copyWith({
    Rect? boundingBox,
    String? text,
    List<TextLine>? lines,
    DateTime? lastSeen,
    DateTime? lastOcrTime,
  }) {
    return TrackedTextBlock(
      id: id,
      boundingBox: boundingBox ?? this.boundingBox,
      text: text ?? this.text,
      lines: lines ?? this.lines,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
      lastSeen: lastSeen ?? this.lastSeen,
      lastOcrTime: lastOcrTime ?? this.lastOcrTime,
    );
  }

  TextBlock toTextBlock() {
    return TextBlock(
      text: text,
      lines: lines,
      boundingBox: boundingBox,
      recognizedLanguages: recognizedLanguages,
      cornerPoints: cornerPoints,
    );
  }
}
