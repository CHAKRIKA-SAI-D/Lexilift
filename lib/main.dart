import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectedFont = "OpenDyslexic";

  void updateFont(String font) {
    setState(() {
      selectedFont = font;
    });
  }

  String? getFontFamily() {
    if (selectedFont == "Normal") return null;
    if (selectedFont == "OpenDyslexic") return "OpenDyslexic";
    if (selectedFont == "Lexend") return "Lexend";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LexiLift',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: getFontFamily(), // 🔥 Global font toggle
      ),
      home: HomePage(
        selectedFont: selectedFont,
        onFontChanged: updateFont,
      ),
    );
  }
}
