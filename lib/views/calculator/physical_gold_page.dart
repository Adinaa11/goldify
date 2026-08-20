import 'package:flutter/material.dart';

class PhysicalGoldPage extends StatelessWidget {
  const PhysicalGoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Emas Fisik'),
      ),
      body: const Center(
        child: Text(
          'Kalkulator Emas Fisik',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}