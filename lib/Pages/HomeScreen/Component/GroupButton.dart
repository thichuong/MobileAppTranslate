import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Translation/language.dart';

class GroupButton extends StatelessWidget {
  GroupButton({
    this.onChangedLanguage,
    this.selectedLanguage,
    this.onPressedClearButton,
    ClearButton,
    dropdownButtonLanguage,
  });

  final ValueChanged<String?>? onChangedLanguage;
  final String? selectedLanguage;
  final VoidCallback? onPressedClearButton;

  TextButton? ClearButton;
  DropdownButtonLanguage? dropdownButtonLanguage;

  @override
  Widget build(BuildContext context) {
    TextButton ClearButton = TextButton(
        style: TextButton.styleFrom(
          primary: Colors.blue, // background
        ),
        onPressed: onPressedClearButton,
        child: Text('X', style: TextStyle(fontSize: 18))
    );
    DropdownButtonLanguage dropdownButtonLanguage = new DropdownButtonLanguage(
      selectedValue : selectedLanguage,
      onChanged: onChangedLanguage,
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