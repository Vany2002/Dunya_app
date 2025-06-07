import 'package:flutter/material.dart';
import 'screens/love_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoveHomePage(),
    );
  }
}