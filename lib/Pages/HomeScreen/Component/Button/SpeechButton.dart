import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '/Translation/Translation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '/Translation/language.dart';

class SpeechButton extends StatelessWidget {
  SpeechButton({this.onPressedSpeedButton, this.isListening});
  final VoidCallback? onPressedSpeedButton;
  final bool? isListening;

  @override
  Widget build(BuildContext context) {
    Color colorButton = Colors.blueAccent;
    AvatarGlow avatarGlow = new AvatarGlow(
      animate: isListening!,
      glowColor: Theme.of(context).primaryColor,
      endRadius: 50.0,
      duration: const Duration(milliseconds: 2000),
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: FloatingActionButton(
        onPressed: onPressedSpeedButton,
        child: Icon(isListening! ? Icons.mic : Icons.mic_none),
      ),
    );
    return Column(
      children: <Widget>[
        new Container(
          child:
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              avatarGlow,
            ],
          ),
          alignment: Alignment.center,
        ),
      ],
    );
  }
}