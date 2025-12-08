import 'package:flutter/material.dart';
import 'package:samsung_community/screens/welcome_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Rubik',
      ),
      home: const WelcomeScreen(),
    );
  }
}
