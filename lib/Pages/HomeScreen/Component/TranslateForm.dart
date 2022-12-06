import 'package:flutter/material.dart';
import '/Model/Translation/Translation.dart';
import '/Model/SpeechAndText/TextToSpeech.dart';
import 'package:flutter/services.dart';

import 'Button/InputField.dart';
import 'Button/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';
import '/Model/SourceLang.dart';

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

    InputTextController!.addListener(() {
      translatext(InputTextController!.text);
    });
    TextToSpeech.instance.setLang(FromLanguage);
    SourceLang.instance.languageFrom = FromLanguage;
    SourceLang.instance.languageTo = ToLanguage;

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

  void _speak(String text,String lang)
  {
    if(!isSpeak)
      {
        setState(() {
          isSpeak = true;
        });
        TextToSpeech.instance.setLang(lang);
        TextToSpeech.instance.speak(text);
      }
    else
      {
        setState(() {
          isSpeak = false;
        });
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
    TextToSpeech.instance.setcompletionHandler(()
    {
      setState(()
      {isSpeak = false;});
    });
    TextToSpeech.instance.initSetting();
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
    OutlinedButton SwapButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.blueAccent, // text + icon color
        foregroundColor: Colors.blueAccent,
        side: BorderSide(color: Colors.blueAccent),
      ),
      child: Text('Swap', style: TextStyle(fontSize: 13)),
      onPressed: () async {
        FromLanguage = SourceLang.instance.languageIDTo;
        ToLanguage = SourceLang.instance.languageIDFrom;
        SourceLang.instance.languageFrom = FromLanguage;
        SourceLang.instance.languageTo = ToLanguage;
        setState(() {
          InputTextController!.text = OutputTextController.text;
        });
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
                          SourceLang.instance.languageFrom = FromLanguage;
                          translatext(InputTextController!.text);
                        });
                      },
                      onPressedCopyButton: () async {
                        await Clipboard.setData(ClipboardData(text: InputTextController!.text));
                        // copied successfully
                      },
                      onPressedToSpeechButton: () async {_speak(InputTextController!.text,FromLanguage);},
                      isSpeak: isSpeak,
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
                    SwapButton,
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
                          SourceLang.instance.languageTo = ToLanguage;
                          translatext(InputTextController!.text);
                        });
                      },
                      onPressedCopyButton: () async {
                        await Clipboard.setData(ClipboardData(text: OutputTextController.text));
                        // copied successfully
                      },
                      onPressedToSpeechButton: () async {_speak(OutputTextController!.text,ToLanguage);},
                      isSpeak: isSpeak,
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