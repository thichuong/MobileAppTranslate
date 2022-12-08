import 'package:flutter/material.dart';


class InputField extends StatelessWidget {
  const InputField({
    this.controller,
    this.onChanged,
});
  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
          child: new TextFormField (
            controller: controller,
            onChanged: this.onChanged,
            autofocus: true,
            style: new TextStyle(fontSize:18.0,
                //color: const Color(0xFF000000),
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto"),
            maxLines: null,
          ),
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.topLeft,
          height: 200,
        );
  }
}
