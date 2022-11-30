import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'Button/Dropdown_button_language.dart';
import '/Translation/language.dart';

class GroupButton extends StatelessWidget {
  GroupButton({
    this.onChangedLanguage,
    this.selectedLanguage,
    this.onPressedClearButton,
    this.onPressedCopyButton,
    dropdownButtonLanguage,
    ClearButton,
    CopyButton,
  });

  final ValueChanged<String?>? onChangedLanguage;
  final String? selectedLanguage;
  final VoidCallback? onPressedClearButton;
  final VoidCallback? onPressedCopyButton;

  DropdownButtonLanguage? dropdownButtonLanguage;
  TextButton? ClearButton;
  TextButton? CopyButton;

  @override
  Widget build(BuildContext context) {
    Color colorButton = Colors.blueAccent;

    DropdownButtonLanguage dropdownButtonLanguage = new DropdownButtonLanguage(
      selectedValue : selectedLanguage,
      onChanged: onChangedLanguage,
    );
    TextButton ClearButton = TextButton.icon(
      style: TextButton.styleFrom(
        primary: colorButton, // text + icon color
      ),
      icon: Icon(Icons.clear, size: 32),
      label: Text('', style: TextStyle(fontSize: 28)),
      onPressed: onPressedClearButton,
    );
    TextButton CopyButton =  TextButton.icon(
      style: TextButton.styleFrom(
        primary: colorButton, // text + icon color
      ),
      icon: Icon(Icons.copy_all_outlined, size: 32),
      label: Text('', style: TextStyle(fontSize: 28)),
      onPressed: onPressedCopyButton,
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
                        ClearButton,
                        CopyButton,
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