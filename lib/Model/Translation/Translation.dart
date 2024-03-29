import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '/Model/SourceLang.dart';

import 'language.dart';
class Translation
{
  Translation._();
  /// the one and only instance of this singleton
  static final instance = Translation._();
  final translator = GoogleTranslator();
  final LanguageList languageList = LanguageList.instance;
  Future<String> translate (String sourceText, {String languagefrom = 'en', String languageto = 'vi'}) async
  {
    if(sourceText.replaceAll(' ', '').replaceAll('\n','').isEmpty)
      return '';

    var translation = await translator.translate(sourceText, from: languagefrom, to: languageto);
    return translation.text;
  }

}

OnDeviceTranslator GetOnDeviceTranslatorLanguageFromTo()
{
  return OnDeviceTranslator(
      sourceLanguage: SourceLang.instance.TranslateLanguageFrom,
      targetLanguage: SourceLang.instance.TranslateLanguageTo);
}

OnDeviceTranslator GetOnDeviceTranslatorLanguageFrom()
{
  return OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: SourceLang.instance.TranslateLanguageFrom);
}

OnDeviceTranslator GetOnDeviceTranslatorLanguageTo()
{
  return OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: SourceLang.instance.TranslateLanguageTo);
}
