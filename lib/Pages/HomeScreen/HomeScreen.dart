import 'package:flutter/material.dart';

import '/Pages/HomeScreen/Component/TranslateForm.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '/Model/SourceLang.dart';
import '/Pages/HomeScreen/Component/Button/SpeechButton.dart';
import '/Pages/HomeScreen/Component/Button/CameraButton.dart';
import '/Pages/Vision_detector_screen/text_detector_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController InputTextController = TextEditingController();
  final   SpeechToText speech = SpeechToText();

  bool isInitilized = false;

  bool _logEvents = false;
  bool _onDevice = false;

  String lastWords = '';
  String lastError = '';
  String lastStatus = '';

  late TranslateForm _TranslateForm;
  @override
  void initState() {
    initSpeechState();

    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    InputTextController.dispose();
  }
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
        finalTimeout : Duration(milliseconds: 2000),
      );
    } catch (e) {
      lastError = 'Speech recognition failed: ${e.toString()}';
    }
  }

  void startListening()  {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 50),
      pauseFor: Duration(seconds: 10),
      partialResults: true,
      localeId: SourceLang.instance.languageIDFrom,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      onDevice: _onDevice,
    );
    setState(() {});;
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {});;    //level = 0.0;
  }


  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      InputTextController.text =  result.recognizedWords;
    });
  }


  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    ;
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  void _listen() {
    if (!speech.isListening) {
      print('Start Listening');
      startListening();
    }
    else {
      print('Stop Listening');
      stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _TranslateForm = new TranslateForm(InputTextController: InputTextController , ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CameraButton(onPressed: () async
                  {InputTextController.text = await  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => TextRecognizerView()));}
                ),
                new SpeechButton(
                    onPressedSpeedButton: _listen,
                    isListening: speech.isListening,
                ),
              ],
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}