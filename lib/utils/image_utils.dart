import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class ImageUtils {
  static InputImage? inputImageFromCameraImage({
    required CameraImage image,
    required CameraController controller,
    required List<CameraDescription> cameras,
  }) {
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (GetPlatform.isAndroid) {
      var rotationCompensation = controller.description.sensorOrientation;
      if (controller.description.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (rotationCompensation + 0) % 360;
      } else {
        rotationCompensation = (rotationCompensation - 0 + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else if (GetPlatform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
