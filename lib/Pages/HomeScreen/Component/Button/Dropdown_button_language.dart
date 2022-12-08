import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '/Model/Translation/language.dart';

class DropdownButtonLanguage extends StatelessWidget {
  DropdownButtonLanguage({
    this.onChanged,
    this.selectedValue,
    items,
  });
  final ValueChanged<String?>? onChanged;
  var  items = LanguageList.GetList();
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      // Initial Value
      value: selectedValue,
      // Down Arrow Icon
      icon: null,
      // Array list of items
      items: items.map((Language items) {
        return DropdownMenuItem(
          value: items.code,
          child: Text(items.name),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: onChanged,
      buttonWidth: 150,
    );
  }
}
