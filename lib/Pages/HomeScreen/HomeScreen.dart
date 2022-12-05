import 'package:flutter/material.dart';

import '/Pages/HomeScreen/Component/TranslateForm.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  late TranslateForm _TranslateForm;
  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });

    super.initState();

  }


  @override
  void dispose() {
    super.dispose();
    InputTextController.dispose();
  }
  Future<Null> _startScan() async {
    List<OcrText> list = [];
    String temp = '';
    try {
      list = await FlutterMobileVision.read(
        waitTap: true,
        fps: 1,
        multiple: true,
        forceCloseCameraOnTap: true,
        autoFocus: true,
        camera: FlutterMobileVision.CAMERA_BACK,
        showText: true,
      );
      temp = '';
      for (OcrText text in list) {
        temp = temp + ' ' + (text.value);
        //print('valueis ${text.value}');
      }

    } catch (e) {list.add(OcrText('Failed to recognize text.'));}
    setState(() {
      InputTextController.text = temp;
      print(temp);
    });
  }

  void _listen() async {
    if (!_isListening) {
      String text_temp = InputTextController.text;
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        finalTimeout : Duration(milliseconds: 5000),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            InputTextController.text = text_temp + val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
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
                    isListening: _isListening,
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