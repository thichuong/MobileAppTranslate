import 'package:flutter/material.dart';

import '/Pages/HomeScreen/Component/TranslateForm.dart';
//import 'package:speech_to_text/speech_to_text.dart';
import '/Model/SpeechAndText/SpeechToText.dart';
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
  bool isInitilized = false;
  SpeechTotext _speech = SpeechTotext.instance;
  bool _isListening = false;

  late TranslateForm _TranslateForm;
  @override
  void initState() {
    _speech.initSpeechState();

    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    InputTextController.dispose();
  }

  void _listen() {
    if (!_speech.isListening) {
      print('Start Listening');
      _speech.listenForController = InputTextController;
      _speech.setState = () {setState(() => {});};
      //setState(() => {_speech.startListening()});
      _speech.startListening();
    }
    else {
      print('Stop Listening');
      setState(() => {_speech.stopListening()});
    }
  }

  @override
  Widget build(BuildContext context) {
    _speech.setState = () {setState(() {});};

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
                    isListening: _speech.isListening,
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