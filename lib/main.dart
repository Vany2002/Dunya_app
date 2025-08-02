import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/love_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _selectedColor = Colors.red;

  static const String _colorKey = 'selectedColor';

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.white,
    // Colors.black, // убрал чёрный цвет для упрощения
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      setState(() {
        _selectedColor = Color(colorValue);
      });
    }
  }

  Future<void> _changeTheme(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love App',
      theme: ThemeData.light(),
      home: LoveHomePage(
        onThemeChange: _changeTheme,
        currentColor: _selectedColor,
        availableColors: _colors,
      ),
    );
  }
}