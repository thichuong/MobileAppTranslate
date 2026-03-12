import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService extends GetxService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  RxBool isListening = false.obs;

  Future<void> initSpeech() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  Future<void> startListening(Function(String) onResult, {String? localeId}) async {
    if (await _speechToText.initialize()) {
      isListening.value = true;
      await _speechToText.listen(
        localeId: localeId,
        onResult: (result) {
          if (result.finalResult) {
            isListening.value = false;
            onResult(result.recognizedWords);
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }

  Future<void> speak(String text, String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}
