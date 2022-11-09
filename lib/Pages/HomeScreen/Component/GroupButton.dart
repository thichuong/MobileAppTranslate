import 'package:flutter/material.dart';
import '/Translation/Translation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '/Pages/HomeScreen/Component/Dropdown_button_language.dart';
import '/Translation/language.dart';

class GroupButton extends StatelessWidget {
  GroupButton({
    this.onChangedLanguage,
    this.selectedLanguage,
  });
  final ValueChanged<String?>? onChangedLanguage;
  final String? selectedLanguage;

  TextButton ClearButton = new TextButton(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
    ),
    onPressed: () { },
    child: Text('X'),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new Container(
          child:
          new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new DropdownButtonLanguage(
                  selectedValue : selectedLanguage,
                  onChanged: onChangedLanguage,
                ),
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