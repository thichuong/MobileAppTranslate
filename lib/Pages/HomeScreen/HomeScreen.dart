import 'package:flutter/material.dart';
import '/Translation/Translation.dart';

import '/Pages/HomeScreen/Component/InputField.dart';
import '/Pages/HomeScreen/Component/TranslateOutText.dart';
import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Translation/language.dart';

final String textInput = "";

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
            new Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new DropdownButtonLanguage(
                selectedValue : FromLanguage,
                onChanged: (value)
                {
                  setState(() {
                    FromLanguage = value!;
                    translatext(_InputTextController.text);
                  });
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
        ),
      ),
    );
  }
}