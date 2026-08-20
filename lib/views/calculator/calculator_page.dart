import 'package:flutter/material.dart';

import 'physical_gold_page.dart';
import 'pivot_point_page.dart';
import 'physical_gold_info_page.dart';
import 'pivot_point_info_page.dart';

class CalculatorPage extends StatelessWidget {
  final VoidCallback onBack;

  const CalculatorPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==============================================================
      // HEADER
      // ==============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.26),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFF7931E),
            size: 22,
          ),
          onPressed: onBack,
        ),

        title: const Text(
          'Kalkulator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),

        titleSpacing: 0,
      ),

      // ==============================================================
      // BODY
      // ==============================================================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ========================================================
              // JUDUL
              // ========================================================
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                  children: [
                    TextSpan(
                      text: 'Pilih Jenis ',
                    ),
                    TextSpan(
                      text: 'Kalkulator',
                      style: TextStyle(
                        color: Color(0xFFF7931E),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ========================================================
              // SUBJUDUL
              // ========================================================
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF444444),
                  ),
                  children: [
                    TextSpan(
                      text: 'Silakan pilih jenis ',
                    ),
                    TextSpan(
                      text: 'kalkulator',
                      style: TextStyle(
                        color: Color(0xFFF7931E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' yang ingin Anda gunakan untuk memulai perhitungan.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ========================================================
              // KALKULATOR EMAS FISIK
              // ========================================================
              _buildCalculatorCard(
                context: context,
                icon: Icons.calculate_outlined,
                title: 'Kalkulator Emas Fisik',
                description:
                    'Platform kalkulator emas yang membantu Anda melakukan perhitungan potensi keuntungan atau kerugian emas fisik dengan lebih mudah dan informatif.',
                gradientColors: const [
                  Color(0xFFFFF8F0),
                  Color(0xFFFFE6C9),
                  Color(0xFFFFF3E6),
                ],

                // ------------------------------------------------------
                // INFORMASI EMAS FISIK
                // ------------------------------------------------------
                onInformation: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const PhysicalGoldInfoDialog();
                    },
                  );
                },

                // ------------------------------------------------------
                // HITUNG EMAS FISIK
                // ------------------------------------------------------
                onCalculate: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhysicalGoldPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ========================================================
              // KALKULATOR PIVOT POINT
              // ========================================================
              _buildCalculatorCard(
                context: context,
                icon: Icons.show_chart,
                title: 'Kalkulator Pivot Point',
                description:
                    'Platform kalkulator emas dan analisis pasar yang membantu Anda melakukan perhitungan dengan lebih mudah dan informatif.',
                gradientColors: const [
                  Color(0xFFFFFCF8),
                  Color(0xFFFFF0DF),
                  Color(0xFFFFF7ED),
                ],

                // ------------------------------------------------------
                // INFORMASI PIVOT POINT
                // ------------------------------------------------------
                onInformation: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const PivotPointInfoDialog();
                    },
                  );
                },

                // ------------------------------------------------------
                // HITUNG PIVOT POINT
                // ------------------------------------------------------
                onCalculate: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PivotPointPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CARD KALKULATOR
  // ================================================================
  Widget _buildCalculatorCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onInformation,
    required VoidCallback onCalculate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        // ------------------------------------------------------------
        // GRADASI CARD
        // ------------------------------------------------------------
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),

        borderRadius: BorderRadius.circular(12),

        // ------------------------------------------------------------
        // BORDER
        // ------------------------------------------------------------
        border: Border.all(
          color: const Color(0xFFE8B77D),
          width: 1.2,
        ),

        // ------------------------------------------------------------
        // SHADOW
        // ------------------------------------------------------------
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // ICON + JUDUL
          // ==========================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------------
              // ICON
              // ------------------------------------------------------
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.80),
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFFF7931E),
                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF7931E).withValues(
                        alpha: 0.12,
                      ),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFFF7931E),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // ------------------------------------------------------
              // JUDUL
              // ------------------------------------------------------
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                    children: [
                      TextSpan(
                        text: title.startsWith('Kalkulator ')
                            ? 'Kalkulator '
                            : title,
                      ),

                      TextSpan(
                        text: title == 'Kalkulator Emas Fisik'
                            ? 'Emas Fisik'
                            : title == 'Kalkulator Pivot Point'
                                ? 'Pivot Point'
                                : '',
                        style: const TextStyle(
                          color: Color(0xFFF7931E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // DESKRIPSI
          // ==========================================================
          Padding(
            padding: const EdgeInsets.only(
              left: 54,
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
                color: Color(0xFF444444),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==========================================================
          // TOMBOL
          // ==========================================================
          Row(
            children: [
              // ------------------------------------------------------
              // INFORMASI
              // ------------------------------------------------------
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: onInformation,

                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF7931E),

                      side: const BorderSide(
                        color: Color(0xFFF7931E),
                        width: 1.2,
                      ),

                      backgroundColor: Colors.white.withValues(
                        alpha: 0.55,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),

                    child: const Text(
                      'INFORMASI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ------------------------------------------------------
              // HITUNG
              // ------------------------------------------------------
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: onCalculate,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7931E),
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'HITUNG',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 5),

                        Icon(
                          Icons.arrow_forward,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}