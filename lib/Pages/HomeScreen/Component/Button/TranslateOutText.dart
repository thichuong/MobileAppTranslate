import 'package:flutter/material.dart';
import '/Model/Translation/Translation.dart';


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
          child: new SingleChildScrollView(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new TextFormField(
                    controller: controller,
                    autofocus: true,
                    readOnly: true,
                    style: new TextStyle(fontSize:18.0,
                        //color: const Color(0xFF000000),
                        fontWeight: FontWeight.w200,
                        fontFamily: "Roboto"),
                    maxLines: null,
                  )
                ]

            ),
          ),
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.topLeft,
          height: 170,
        ),
      ],
    );
  }
}
