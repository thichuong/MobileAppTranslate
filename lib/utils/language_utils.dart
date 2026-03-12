import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageUtils {
  /// Maps ML Kit [TranslateLanguage] to BCP47 locale strings for STT and TTS.
  static String getBCP47(TranslateLanguage lang) {
    switch (lang) {
      case TranslateLanguage.english:
        return 'en-US';
      case TranslateLanguage.vietnamese:
        return 'vi-VN';
      case TranslateLanguage.japanese:
        return 'ja-JP';
      case TranslateLanguage.korean:
        return 'ko-KR';
      case TranslateLanguage.chinese:
        return 'zh-CN';
      case TranslateLanguage.french:
        return 'fr-FR';
      case TranslateLanguage.german:
        return 'de-DE';
      case TranslateLanguage.spanish:
        return 'es-ES';
      case TranslateLanguage.russian:
        return 'ru-RU';
      case TranslateLanguage.italian:
        return 'it-IT';
      case TranslateLanguage.thai:
        return 'th-TH';
      case TranslateLanguage.hindi:
        return 'hi-IN';
      case TranslateLanguage.arabic:
        return 'ar-SA';
      case TranslateLanguage.portuguese:
        return 'pt-PT';
      case TranslateLanguage.dutch:
        return 'nl-NL';
      case TranslateLanguage.indonesian:
        return 'id-ID';
      case TranslateLanguage.turkish:
        return 'tr-TR';
      case TranslateLanguage.polish:
        return 'pl-PL';
      case TranslateLanguage.swedish:
        return 'sv-SE';
      default:
        // ML Kit enums usually have the language name as the last part
        // Example: TranslateLanguage.english -> 'en'
        // This is a rough fallback - use the first 2 letters of the name
        String name = lang.toString().split('.').last;
        if (name.length >= 2) {
          return name.substring(0, 2);
        }
        return 'en-US'; // Absolute fallback
    }
  }
}
