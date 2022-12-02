import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '/Translation/language.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({this.onPressed});
  final VoidCallback? onPressed;

  Future<Null> _startScan() async {
    String temp = '';
  }


  @override
  Widget build(BuildContext context) {
    Color colorButton = Colors.blueAccent;
    FloatingActionButton SpeechActionButton = new FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Increment',
      child: Icon(Icons.camera_alt),
    );

    return Column(
      children: <Widget>[
        new Container(
          child:
            SpeechActionButton,
          alignment: Alignment.center,
        ),
      ],
    );
  }
}