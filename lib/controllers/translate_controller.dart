import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';
import '../services/permission_service.dart';
import '../utils/language_utils.dart';

class TranslateController extends GetxController {
  final TranslationService _translationService = Get.find<TranslationService>();
  final SpeechService _speechService = Get.find<SpeechService>();
  final PermissionService _permissionService = Get.find<PermissionService>();

  late SharedPreferences _prefs;

  final sourceLanguage = TranslateLanguage.english.obs;
  final targetLanguage = TranslateLanguage.vietnamese.obs;

  final inputText = "".obs;
  final translatedText = "".obs;

  final isLoading = false.obs;
  final isModelDownloading = false.obs;

  final TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadSavedLanguages();

    // Listen to text changes for instant translation (with debounce)
    debounce(inputText, (_) => translate(),
        time: const Duration(milliseconds: 500));
  }

  void _loadSavedLanguages() {
    final sourceKey = _prefs.getString('sourceLanguage');
    final targetKey = _prefs.getString('targetLanguage');

    if (sourceKey != null) {
      sourceLanguage.value = TranslateLanguage.values.firstWhere(
        (e) => e.toString() == sourceKey,
        orElse: () => TranslateLanguage.english,
      );
    }
    if (targetKey != null) {
      targetLanguage.value = TranslateLanguage.values.firstWhere(
        (e) => e.toString() == targetKey,
        orElse: () => TranslateLanguage.vietnamese,
      );
    }
  }

  void _saveLanguages() {
    _prefs.setString('sourceLanguage', sourceLanguage.value.toString());
    _prefs.setString('targetLanguage', targetLanguage.value.toString());
  }

  void swapLanguages() {
    final temp = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    targetLanguage.value = temp;
    _saveLanguages();
    translate();
  }

  Future<void> translate() async {
    if (inputText.value.isEmpty) {
      translatedText.value = "";
      return;
    }

    isLoading.value = true;
    try {
      await _translationService.initTranslator(
        sourceLanguage: sourceLanguage.value,
        targetLanguage: targetLanguage.value,
      );

      final result = await _translationService.translateText(inputText.value);
      translatedText.value = result;
    } catch (e) {
      translatedText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startVoiceTranslation() async {
    final granted = await _permissionService.requestMicrophonePermission();
    if (!granted) {
      Get.snackbar("Permission Denied",
          "Microphone access is required for voice translation.");
      return;
    }


    final String localeId = LanguageUtils.getBCP47(sourceLanguage.value);
    await _speechService.startListening((recognizedWords) {
      textEditingController.text = recognizedWords;
      inputText.value = recognizedWords;
    }, localeId: localeId);
  }

  Future<void> stopVoiceTranslation() async {
    await _speechService.stopListening();
  }

  Future<void> speakResult() async {
    if (translatedText.value.isNotEmpty) {
      String langCode = LanguageUtils.getBCP47(targetLanguage.value);
      await _speechService.speak(translatedText.value, langCode);
    }
  }

  Future<bool> requestCameraPermission() async {
    return await _permissionService.requestCameraPermission();
  }

  void clearText() {
    textEditingController.clear();
    inputText.value = "";
    translatedText.value = "";
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }
}
