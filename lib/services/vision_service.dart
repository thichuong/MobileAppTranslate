import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VisionService extends GetxService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  ObjectDetector? _objectDetector;

  Future<void> initObjectDetector() async {
    // Custom model path: assets/ml/object_labeler.tflite
    // Note: The file must exist for this to work. We will add a placeholder or handle the error.
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<RecognizedText> recognizeText(InputImage inputImage) async {
    return await _textRecognizer.processImage(inputImage);
  }

  Future<List<DetectedObject>> detectObjects(InputImage inputImage) async {
    if (_objectDetector == null) await initObjectDetector();
    return await _objectDetector!.processImage(inputImage);
  }

  Future<void> closeRecognizers() async {
    await _textRecognizer.close();
    await _objectDetector?.close();
  }

  @override
  void onClose() {
    closeRecognizers();
    super.onClose();
  }
}
