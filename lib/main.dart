import 'package:flutter/material.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const GoldifyApp());
}

class GoldifyApp extends StatelessWidget {
  const GoldifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Goldify',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}