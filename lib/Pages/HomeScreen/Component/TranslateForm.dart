import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:flutter/services.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';

import 'package:flutter/material.dart';
import '/Translation/Translation.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';


import '/Translation/language.dart';

class TranslateForm extends StatefulWidget {
  const TranslateForm({Key? key}) : super(key: key);

  @override
  State<TranslateForm> createState() => _TranslateForm();
}

class _TranslateForm extends State<TranslateForm> {
  final TextEditingController _InputTextController = TextEditingController();
  final TextEditingController _OutputTextController = TextEditingController();
  var FromLanguage = 'en';
  var ToLanguage = 'vi';
  @override
  void initState() {
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


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Column(
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
            ),
          ],
        );
  }
}