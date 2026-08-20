import 'package:flutter/material.dart';

class PivotPointPage extends StatelessWidget {
  const PivotPointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Pivot Point'),
      ),
      body: const Center(
        child: Text(
          'Kalkulator Pivot Point',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}