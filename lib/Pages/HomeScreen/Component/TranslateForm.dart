import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:flutter/services.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
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
    print(textIn);
    if(textIn.replaceAll(' ', '').replaceAll('\n','').isEmpty)
    {
      setState(()  {
        OutputTextController.text = '';
      });
      return;
    }
    var textTemp = await Translation.instance.translate(textIn,languagefrom : FromLanguage,languageto: ToLanguage);
    setState(()  {
      OutputTextController.text = '$textTemp';
    });
  }

  void ClearOnPress()
  {
    setState(()  {
      InputTextController!.text = '';
      OutputTextController.text = '';
    });
  }

  @override
  void dispose() {
    InputTextController!.dispose();
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
      InputTextController!.text = temp;
      translatext(temp);
    });
  }


  @override
  Widget build(BuildContext context) {
    InputTextController!.addListener(() {
      translatext(InputTextController!.text);
    });

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
                        translatext(InputTextController!.text);
                      });
                    },
                    onPressedClearButton: ClearOnPress,
                    onPressedCopyButton: () async {
                      await Clipboard.setData(ClipboardData(text: OutputTextController.text));
                      // copied successfully
                    },
                  ),
                  new InputField(
                    controller : InputTextController,
                    onChanged : (text) {
                      //translatext(text);
                    },
                  ),
                  new DropdownButtonLanguage(
                    selectedValue : ToLanguage,
                    onChanged: (value)
                    {
                      setState(() {
                        ToLanguage = value!;
                        translatext(InputTextController!.text);
                      });
                    },
                  ),
                  new TranslateOutText(
                    controller : OutputTextController,
                  ),
                ],
              ),
          height: 500,
        ),
      ],
    );
  }
}