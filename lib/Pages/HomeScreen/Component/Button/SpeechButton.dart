import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '/Model/SpeechAndText/SpeechToText.dart';

class SpeechButton extends StatelessWidget {
  SpeechButton( {
    this.onPressedSpeedButton,
    this.isListening,
  });
  final VoidCallback? onPressedSpeedButton;
  final bool? isListening;


  @override
  Widget build(BuildContext context) {
    AvatarGlow avatarGlow = new AvatarGlow(
      animate: isListening!,
      glowColor: Theme.of(context).primaryColor,
      endRadius: 50.0,
      duration: const Duration(milliseconds: 1000),
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: FloatingActionButton(
        onPressed: onPressedSpeedButton,
        child: Icon(isListening! ? Icons.square : Icons.mic),
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