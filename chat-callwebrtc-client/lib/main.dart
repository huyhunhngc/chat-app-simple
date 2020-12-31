import 'package:flutter/material.dart';
import 'package:BKZalo/view/loginui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Colors.white,
              elevation: 0.0,
              textTheme: Theme.of(context).textTheme,
              iconTheme: IconThemeData(color: Colors.black),
              actionsIconTheme: IconThemeData(color: Colors.black)),
          primarySwatch: Colors.blue,
          primaryColor: Color(0xff0084FF)),
      home: Login(),
    );
  }
}
