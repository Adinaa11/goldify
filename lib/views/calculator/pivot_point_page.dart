import 'package:flutter/material.dart';
import 'pivot_result_page.dart';

class PivotPointPage extends StatefulWidget {
  const PivotPointPage({super.key});

  @override
  State<PivotPointPage> createState() => _PivotPointPageState();
}

class _PivotPointPageState extends State<PivotPointPage> {
  final TextEditingController _highController = TextEditingController();
  final TextEditingController _lowController = TextEditingController();
  final TextEditingController _closeController = TextEditingController();

  // WARNA
  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF555555);
  static const Color fieldColor = Color(0xFFF7F5F3);

  @override
  void dispose() {
    _highController.dispose();
    _lowController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  // FORMAT INPUT
  double? _parseNumber(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  // HITUNG PIVOT POINT
  void _calculatePivot() {
    final double? high = _parseNumber(_highController.text);
    final double? low = _parseNumber(_lowController.text);
    final double? close = _parseNumber(_closeController.text);

    // VALIDASI INPUT
    if (high == null || low == null || close == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon isi Harga High, Low, dan Close dengan benar.',
          ),
          backgroundColor: orange,
        ),
      );
      return;
    }

    // VALIDASI HIGH > LOW
    if (high <= low) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harga High harus lebih besar dari Harga Low.',
          ),
          backgroundColor: orange,
        ),
      );
      return;
    }

    // PINDAH HASIL
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PivotResultPage(
          high: high,
          low: low,
          close: close,
        ),
      ),
    );
  }

  // RESET INPUT
  void _resetInput() {
    _highController.clear();
    _lowController.clear();
    _closeController.clear();

    setState(() {});
  }

  // INPUT FIELD
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            height: 52,
            decoration: BoxDecoration(
              color: fieldColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade600,
                  width: 1.2,
                ),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                color: darkText,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                prefixStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  color: greyText,
                ),
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.20),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: orange,
            size: 21,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            children: [
              TextSpan(
                text: 'Kalkulator ',
              ),
              TextSpan(
                text: 'Pivot',
                style: TextStyle(
                  color: orange,
                ),
              ),
            ],
          ),
        ),
      ),

      // BODY
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DESKRIPSI
                const Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 10,
                  ),
                  child: Text(
                    'Hitung titik keseimbangan atau level '
                    'harga acuan berdasarkan pergerakan '
                    'harga pada periode sebelumnya.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: darkText,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // CARD INPUT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    10,
                    8,
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCFA),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFE6D7CA),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: orange,
                          width: 3,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 9,
                      right: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // JUDUL CARD
                        Row(
                          children: [
                            const Icon(
                              Icons.input,
                              color: orange,
                              size: 19,
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              'Input Perhitungan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // HIGH
                        _buildInputField(
                          label: 'Harga High',
                          hint: '4405',
                          controller: _highController,
                        ),

                        // LOW
                        _buildInputField(
                          label: 'Harga Low',
                          hint: '4402',
                          controller: _lowController,
                        ),

                        // CLOSE
                        _buildInputField(
                          label: 'Harga Close',
                          hint: '4400',
                          controller: _closeController,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 62),

                // BTN HITUNG
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _calculatePivot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate,
                            size: 19,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'Hitung',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // BTN RESET
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: _resetInput,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkText,
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // DEKORASI BAWAH
          Positioned(
            right: -50,
            bottom: -65,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      orange.withValues(alpha: 0.10),
                      orange.withValues(alpha: 0.35),
                      const Color(0xFFE94B20).withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}