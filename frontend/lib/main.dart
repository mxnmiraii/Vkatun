import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VKatun',
      home: Scaffold(
        appBar: AppBar(
          title: Text('VKatun App'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Help', style: TextStyle(
            fontFamily: 'Playfair',
            fontWeight: FontWeight.w300,
            fontSize: 24,
            color: Colors.deepPurple,
          ),),
        ),
      )
    );
  }

}
