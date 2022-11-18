import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:flutter/services.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';


import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class TranslateForm extends StatefulWidget {
  const TranslateForm({Key? key}
      ) : super(key: key);

  @override
  State<TranslateForm> createState() => _TranslateForm();
}

class _TranslateForm extends State<TranslateForm> {
  final TextEditingController _InputTextController = TextEditingController();
  final TextEditingController _OutputTextController = TextEditingController();
  var FromLanguage = 'en';
  var ToLanguage = 'vi';

  bool isInitilized = false;

  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });
    super.initState();
  }

  void translatext(String textIn) async
  {
    if(textIn.replaceAll(' ', '').replaceAll('\n','').isEmpty)
    {
      _OutputTextController.text = '';
      return;
    }
    var textTemp = await Translation.instance.translate(textIn,languagefrom : FromLanguage,languageto: ToLanguage);
    setState(()  {
      _OutputTextController.text = '$textTemp';
    });
  }

  void ClearOnPress()
  {
    setState(()  {
      _InputTextController.text = '';
      _OutputTextController.text = '';
    });
  }

  @override
  void dispose() {
    _InputTextController.dispose();
    super.dispose();
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
        print('valueis ${text.value}');
      }

    } catch (e) {list.add(OcrText('Failed to recognize text.'));}
    setState(() {
      _InputTextController.text = temp;
      translatext(temp);
    });
  }


  @override
  Widget build(BuildContext context) {
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
                  new GroupButton(
                    selectedLanguage : FromLanguage,
                    onChangedLanguage: (value)
                    {
                      setState(() {
                        FromLanguage = value!;
                        translatext(_InputTextController.text);
                      });
                    },
                    onPressedClearButton: ClearOnPress,
                    onPressedCopyButton: () async {
                      await Clipboard.setData(ClipboardData(text: _OutputTextController.text));
                      // copied successfully
                    },
                  ),
                  new InputField(
                    controller : _InputTextController,
                    onChanged : (text) {
                      translatext(text);
                    },
                  ),
                  new DropdownButtonLanguage(
                    selectedValue : ToLanguage,
                    onChanged: (value)
                    {
                      setState(() {
                        ToLanguage = value!;
                        translatext(_InputTextController.text);
                      });
                    },
                  ),
                  new TranslateOutText(
                    controller : _OutputTextController,
                  ),
                ],
              ),
          height: 500,
        ),
        new FloatingActionButton(
          onPressed: _startScan,
          tooltip: 'Increment',
          child: Icon(Icons.camera_alt),
            ),
      ],
    );
  }
}