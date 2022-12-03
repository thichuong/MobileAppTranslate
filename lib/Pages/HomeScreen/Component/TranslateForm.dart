import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import '/SpeechAndText/TextToSpeech.dart';
import 'package:flutter/services.dart';

import 'Button/InputField.dart';
import 'Button/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';

import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class TranslateForm extends StatefulWidget {
  const TranslateForm({Key? key,required this.InputTextController}
      ) : super(key: key);
  final TextEditingController? InputTextController;
  @override
  State<TranslateForm> createState() => _TranslateForm(this.InputTextController);
}

class _TranslateForm extends State<TranslateForm> {
  _TranslateForm(this.InputTextController);
  final TextEditingController? InputTextController;
  final TextEditingController OutputTextController = TextEditingController();
  var FromLanguage = 'en';
  var ToLanguage = 'vi';
  bool isSpeak = false;
  bool isInitilized = false;

  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });
    InputTextController!.addListener(() {
      translatext(InputTextController!.text);
    });
    super.initState();

  }

  void translatext(String textIn) async
  {
    if(textIn == '')
      {
        setState(()  {
          OutputTextController.text = '';
        });
        return;
      }
    else if(textIn.replaceAll(' ', '').replaceAll('\n','') == '')
    {
      setState(()  {
        OutputTextController.text = '';
      });
      return;
    }
    else {
      var textTemp = await Translation.instance.translate(
          textIn, languagefrom: FromLanguage, languageto: ToLanguage);
      setState(() {
        OutputTextController.text = '$textTemp';
      }
      );
    }
  }

  void ClearOnPress()
  {
    setState(()  {
      InputTextController!.text = '';
      OutputTextController.text = '';
    });
  }

  void _speak(String text)
  {
    if(!isSpeak)
      {
        isSpeak = true;
        TextToSpeech.instance.speak(text);
      }
    else
      {
        isSpeak = false;
        TextToSpeech.instance.stop();
      }
  }
  @override
  void dispose() {
    InputTextController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    //setcompletionHandler
    TextToSpeech.instance.setcompletionHandler(() { isSpeak = false; });
    OutlinedButton ClearButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.blueAccent, // text + icon color
        foregroundColor: Colors.blueAccent,
        side: BorderSide(color: Colors.blueAccent),
      ),
      child: Text('Clear', style: TextStyle(fontSize: 13)),
      onPressed: ClearOnPress,
    );
    OutlinedButton PastButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.blueAccent, // text + icon color
        foregroundColor: Colors.blueAccent,
        side: BorderSide(color: Colors.blueAccent),
      ),
      child: Text('Past', style: TextStyle(fontSize: 13)),
      onPressed: () async {
        ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
        setState(() {
          InputTextController!.text = data!.text!;
        });
        // copied successfully
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new GroupButton(
                      selectedLanguage : FromLanguage,
                      onChangedLanguage: (value)
                      {
                        setState(() {
                          FromLanguage = value!;
                          translatext(InputTextController!.text);
                        });
                      },
                      onPressedClearButton: ClearOnPress,
                      onPressedCopyButton: () async {
                        await Clipboard.setData(ClipboardData(text: InputTextController!.text));
                        // copied successfully
                      },
                      onPressedToSpeechButton: () async {_speak(InputTextController!.text);},
                    ),
                    new InputField(
                      controller : InputTextController,
                      /*onChanged : (text) {
                        //translatext(text);
                      },*/
                    ),
                  ],
                ),
              ),
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PastButton,
                    ClearButton,
                  ],
                ),
              ),
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new GroupButton(
                      selectedLanguage : ToLanguage,
                      onChangedLanguage: (value)
                      {
                        setState(() {
                          ToLanguage = value!;
                          translatext(InputTextController!.text);
                        });
                      },
                      onPressedClearButton: ClearOnPress,
                      onPressedCopyButton: () async {
                        await Clipboard.setData(ClipboardData(text: OutputTextController.text));
                        // copied successfully
                      },
                      onPressedToSpeechButton: () async {_speak(OutputTextController!.text);},
                    ),
                    new TranslateOutText(
                      controller : OutputTextController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          height: 500,
        ),
      ],
    );
  }
}