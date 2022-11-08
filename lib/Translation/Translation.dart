import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'language.dart';
class Translation
{
  final String apiKey = "AIzaSyAIUVCLawmkUybGL_UIDt5FQiHuL8o8i5k";
  final translator = GoogleTranslator();
  final LanguageList languageList = LanguageList();
  Future<String> translate (String sourceText, {String languagefrom = 'en', String languageto = 'vi'}) async
  {
    var translation = await translator.translate(sourceText, from: languagefrom, to: languageto);
    return translation.text;
  }

}