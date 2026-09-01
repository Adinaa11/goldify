// lib/views/history/history_empty.dart
import 'package:flutter/material.dart';

class HistoryEmpty extends StatelessWidget {
  final VoidCallback? onStart;
  const HistoryEmpty({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6F8),
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 30),
          child: Column(
            children: [
              // Circular icon with soft gradient
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFFFF3E6), const Color(0xFFFEE6C7)],
                    center: Alignment.center,
                    radius: 0.9,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.history, color: Color(0xFFF7931E), size: 34),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Belum Ada Riwayat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Mulai lakukan perhitungan emas fisik atau pivot point untuk melihat riwayat Anda di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B6B6B)),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: 220,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Mulai Menghitung'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7931E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}