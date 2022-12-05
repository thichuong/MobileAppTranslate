import 'package:flutter/material.dart';

import 'Button/Dropdown_button_language.dart';

class GroupButton extends StatelessWidget {
  GroupButton({
    this.onChangedLanguage,
    this.selectedLanguage,
    this.onPressedCopyButton,
    this.onPressedToSpeechButton,
    required this.isSpeak,
  });

  final ValueChanged<String?>? onChangedLanguage;
  final String? selectedLanguage;
  final VoidCallback? onPressedCopyButton;
  final VoidCallback? onPressedToSpeechButton;
  final bool? isSpeak;
  DropdownButtonLanguage? dropdownButtonLanguage;
  TextButton? ClearButton;
  TextButton? CopyButton;
  TextButton? ToSpeechButton;
  @override
  Widget build(BuildContext context) {
    Color colorButton = Colors.blueAccent;

    DropdownButtonLanguage dropdownButtonLanguage = new DropdownButtonLanguage(
      selectedValue : selectedLanguage,
      onChanged: onChangedLanguage,
    );
    TextButton CopyButton =  TextButton.icon(
      style: TextButton.styleFrom(
        primary: colorButton, // text + icon color
      ),
      icon: Icon(Icons.copy_all_outlined, size: 32),
      label: Text('', style: TextStyle(fontSize: 28)),
      onPressed: onPressedCopyButton,
    );
    TextButton ToSpeechButton = TextButton.icon(
      style: TextButton.styleFrom(
        primary: colorButton, // text + icon color
      ),
      icon: Icon(
          isSpeak != true
          ? Icons.volume_up_outlined
          : Icons.square,
          size: 32),
      label: Text('', style: TextStyle(fontSize: 28)),
      onPressed: onPressedToSpeechButton,
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
                dropdownButtonLanguage,
                new Container(
                  child:
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CopyButton,
                        ToSpeechButton,
                      ]
                  ),
                  alignment: Alignment.bottomLeft,
                ),
              ],
          ),
          alignment: Alignment.center,
        ),
      ],
    );
  }
}