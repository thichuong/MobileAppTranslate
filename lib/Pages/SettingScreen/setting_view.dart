import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingView extends StatelessWidget {
  SettingView(
      {
        Key? key,
        required this.title,
      })
      : super(key: key);

  final String title;


  Color foregroundColor = Colors.white;
  Color colorButton = Colors.transparent;
  double fontSizeButton = 18;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _body(),
    );
  }

  Widget _body() {


    return ListView(shrinkWrap: true, children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: BorderSide(color: colorButton),
            backgroundColor: colorButton,
            minimumSize: Size(100, 50),
          ),
          child: Text('History',
                        style: TextStyle(fontSize: fontSizeButton)),
          onPressed: () {},
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: BorderSide(color: colorButton),
            backgroundColor: colorButton,
            minimumSize: Size(100, 50),
          ),
          child: Text('Language',
                      style: TextStyle(fontSize: fontSizeButton)),
          onPressed: () { },
        ),
      ),
    ]);
  }


}
