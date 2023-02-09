import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';


InputImage? ToInputImage(CameraImage image, CameraDescription camera) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize =
  Size(image.width.toDouble(), image.height.toDouble());

  //final camera = cameras[_cameraIndex];
  final imageRotation =
  InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (imageRotation == null) return null;

  final inputImageFormat =
  InputImageFormatValue.fromRawValue(image.format.raw);
  if (inputImageFormat == null) return null;

  final planeData = image.planes.map(
        (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  final inputImage =
  InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  return inputImage;
}
