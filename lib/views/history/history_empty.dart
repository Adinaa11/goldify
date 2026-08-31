import 'package:flutter/material.dart';
import 'dart:math';

class HistoryEmpty extends StatefulWidget {
  final VoidCallback onStart;
  const HistoryEmpty({super.key, required this.onStart});

  @override
  State<HistoryEmpty> createState() => _HistoryEmptyState();
}

class _HistoryEmptyState extends State<HistoryEmpty> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconCircleSize = width * 0.28;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final angle = _ctrl.value * 2 * pi;
                return Transform.rotate(angle: angle, child: child);
              },
              child: Container(
                width: iconCircleSize,
                height: iconCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [Color(0xFFFFF3E6), Color(0xFFFFE6C8)], center: Alignment.center, radius: 0.8),
                  boxShadow: [BoxShadow(color: const Color(0xFFF7931E).withOpacity(0.12), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: Container(
                    width: iconCircleSize * 0.45,
                    height: iconCircleSize * 0.45,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(Icons.access_time, size: iconCircleSize * 0.22, color: const Color(0xFFF7931E)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Belum Ada Riwayat', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 8),
            const Text('Mulai lakukan perhitungan emas fisik atau pivot point\nuntuk melihat riwayat Anda di sini.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onStart,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Mulai Menghitung', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7931E), elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), shadowColor: const Color(0xFFF7931E).withOpacity(0.35)),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}