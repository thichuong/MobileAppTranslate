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
    Color colorButton = Colors.blueAccent.shade400;
    double iconSize = 30;
    DropdownButtonLanguage dropdownButtonLanguage = new DropdownButtonLanguage(
      selectedValue : selectedLanguage,
      onChanged: onChangedLanguage,
    );
    TextButton CopyButton =  TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 10),
      ),
      child: Icon(Icons.copy_all_outlined,
          size: iconSize,
          color: colorButton),
      onPressed: onPressedCopyButton,

    );
    TextButton ToSpeechButton = TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 10),
      ),
      child: Icon(
          isSpeak != true
          ? Icons.volume_up_outlined
          : Icons.square,
          size: iconSize,
          color:  colorButton),
      onPressed: onPressedToSpeechButton,
    );

    return Container(
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
        );
  }
}