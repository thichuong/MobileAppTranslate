import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService extends GetxService {
  OnDeviceTranslator? _translator;
  bool isModelDownloaded = false;

  Future<void> initTranslator({
    required TranslateLanguage sourceLanguage,
    required TranslateLanguage targetLanguage,
  }) async {
    await closeTranslator();
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  Future<String> translateText(String text) async {
    if (_translator == null) return "Translator not initialized";
    try {
      return await _translator!.translateText(text);
    } catch (e) {
      return "Translation error: $e";
    }
  }

  Future<bool> downloadModel(TranslateLanguage language) async {
    final modelManager = OnDeviceTranslatorModelManager();
    return await modelManager
        .downloadModel(language.toString().split('.').last);
  }

  Future<void> closeTranslator() async {
    await _translator?.close();
    _translator = null;
  }

  @override
  void onClose() {
    closeTranslator();
    super.onClose();
  }
}
