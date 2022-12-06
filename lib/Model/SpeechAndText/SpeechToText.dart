import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter/material.dart';
import '/Model/SourceLang.dart';
class SpeechTotext {
  SpeechToText speech = SpeechToText();
  SpeechTotext._();
  static final instance = SpeechTotext._();
  late void Function() _setState;

  set setState(Function() setState) =>{ this._setState = setState };

  bool _hasSpeech = false;
  bool _logEvents = false;
  bool _onDevice = false;

  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  String temp = '';

  late TextEditingController? _listenForController;

  set listenForController(TextEditingController? listenForController) => {this._listenForController = listenForController};

  SpeechToText get speechToText => this.speech;
  bool get isListening => this.speech.isListening;

  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
        finalTimeout : Duration(milliseconds: 5000),
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
        _hasSpeech = hasSpeech;
    } catch (e) {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
    }
  }

  void startListening()  {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    //final pauseFor = int.tryParse(_pauseForController.text);
    //final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimun, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    temp = _listenForController!.text;
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: SourceLang.instance.languageIDFrom,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      onDevice: _onDevice,
    );
    _setState;
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    _setState;
    //level = 0.0;
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    _setState;
    /*setState(() {
      level = 0.0;
    });*/
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    _listenForController!.text = temp + result.recognizedWords;
    _setState;
    /*setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
    });*/
  }


  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    _setState;
    /*setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });*/
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    _setState;
    /*setState(() {
      lastStatus = '$status';
    });*/
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }


}
