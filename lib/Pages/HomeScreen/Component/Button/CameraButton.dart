import 'package:flutter/material.dart';


class CameraButton extends StatelessWidget {
  const CameraButton({this.onPressed, this.child});
  final VoidCallback? onPressed;
  final Widget? child;
  Future<Null> _startScan() async {
    String temp = '';
  }


  @override
  Widget build(BuildContext context) {
    Color colorButton = Colors.blueAccent;
    FloatingActionButton SpeechActionButton = new FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Increment',
      child: child,
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