import 'package:flutter/material.dart';

import '/Pages/HomeScreen/Component/TranslateForm.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController InputTextController = TextEditingController();
  bool isInitilized = false;
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
            new TranslateForm(InputTextController: InputTextController , ),
            new FloatingActionButton(
              onPressed: _startScan,
              tooltip: 'Increment',
              child: Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}