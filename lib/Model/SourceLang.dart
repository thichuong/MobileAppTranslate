import '/Model/Translation/language.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class SourceLang
{
  SourceLang._();
  /// the one and only instance of this singleton
  static final instance = SourceLang._();
  String _text = '';
  Language _languagefrom = LanguageList.instance['en'];
  Language _languageto = LanguageList.instance['vi'];


  set  Text(String text) => {this._text = text};
  String get Text => _text;

  set  languageFrom(String language) => {this._languagefrom = LanguageList.instance[language]};
  String get languageIDFrom => _languagefrom.code;
  String get languageNameFrom => _languagefrom.toString();
  TranslateLanguage get TranslateLanguageFrom =>
      TranslateLanguage.values.firstWhere((element) => element.bcpCode == _languagefrom.code);

  set  languageTo(String language) => {this._languageto = LanguageList.instance[language]};
  String get languageIDTo => _languageto.code;
  String get languageNameTo => _languageto.toString();
  TranslateLanguage get TranslateLanguageTo =>
      TranslateLanguage.values.firstWhere((element) => element.bcpCode == _languageto.code);

}


