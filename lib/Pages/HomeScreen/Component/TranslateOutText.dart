import 'package:flutter/material.dart';
import '/Translation/Translation.dart';


class TranslateOutText extends StatelessWidget {
  const TranslateOutText({
    this.controller,
  });
  //final TextEditingController? TranslateText;
  final TextEditingController? controller;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new Container(
          child:
          new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new TextField(
                  controller: controller,
                  autofocus: true,
                  style: new TextStyle(fontSize:18.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                  maxLines: null,
                )
              ]

          ),

          alignment: Alignment.center,
          width: 1.7976931348623157e+308,
        ),

      ],
    );
  }
}
