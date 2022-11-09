import 'package:flutter/material.dart';
import '/Translation/Translation.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Pages/HomeScreen/Component/GroupButton.dart';
import '/Pages/HomeScreen/Component/TranslateForm.dart';

import '/Translation/language.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            new TranslateForm(),
          ],
        ),
      ),
    );
  }
}