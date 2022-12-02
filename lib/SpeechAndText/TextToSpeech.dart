import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TextToSpeech {
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String langCode = "en-US";
  FlutterTts flutterTts = FlutterTts();

  TextToSpeech._();
  static final instance = TextToSpeech._();

  void setcompletionHandler(VoidCallback? completionHandler)
  {
    flutterTts.completionHandler = completionHandler;
  }
  void initSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(langCode);
  }

  void setLang(String lang) async
  {
    await flutterTts.setLanguage(lang);
  }
  void speak(String text) async {
    initSetting();
    await flutterTts.speak(text);
  }

  void stop() async {
    await flutterTts.stop();
  }
}