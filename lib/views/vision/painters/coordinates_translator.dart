import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

double translateX(
  double x,
  InputImageRotation rotation,
  Size size,
  Size absoluteImageSize,
) {
  final double scaleX = (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg)
      ? size.width / absoluteImageSize.height
      : size.width / absoluteImageSize.width;

  final double scaleY = (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg)
      ? size.height / absoluteImageSize.width
      : size.height / absoluteImageSize.height;

  final double scale = scaleX > scaleY ? scaleX : scaleY;
  final double offsetX = (size.width -
          ((rotation == InputImageRotation.rotation90deg ||
                  rotation == InputImageRotation.rotation270deg)
              ? absoluteImageSize.height
              : absoluteImageSize.width) *
              scale) /
      2;

  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * scale + offsetX;
    case InputImageRotation.rotation270deg:
      return size.width - x * scale - offsetX;
    default:
      return x * scale + offsetX;
  }
}

double translateY(
  double y,
  InputImageRotation rotation,
  Size size,
  Size absoluteImageSize,
) {
  final double scaleX = (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg)
      ? size.width / absoluteImageSize.height
      : size.width / absoluteImageSize.width;

  final double scaleY = (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg)
      ? size.height / absoluteImageSize.width
      : size.height / absoluteImageSize.height;

  final double scale = scaleX > scaleY ? scaleX : scaleY;
  final double offsetY = (size.height -
          ((rotation == InputImageRotation.rotation90deg ||
                  rotation == InputImageRotation.rotation270deg)
              ? absoluteImageSize.width
              : absoluteImageSize.height) *
              scale) /
      2;

  return y * scale + offsetY;
}
