import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import '../calculator/physical_gold_page.dart';

class HistoryDetailEmasPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  HistoryDetailEmasPage({
    super.key,
    required this.item,
    required this.index,
  });

  final ScreenshotController screenshotController = ScreenshotController();

  Map<String, dynamic> get detail =>
      Map<String, dynamic>.from(item['detail'] ?? {});

  double _number(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatRupiah(dynamic value) {
    final number = _number(value).truncate();
    final negative = number < 0;
    final digits = number.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}Rp ${buffer.toString()}';
  }

  String _formatNumber(dynamic value) {
    final number = _number(value).truncate();
    final digits = number.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '${number < 0 ? '-' : ''}${buffer.toString()}';
  }

  String _formatToz(dynamic value) {
    final number = _number(value);
    return number.toStringAsFixed(2).replaceAll('.', ',');
  }

  bool get isProfit {
    final step5 = _number(detail['step5']);
    return step5 >= 0;
  }

  String get resultText => isProfit ? 'PROFIT' : 'LOSS';

  Future<void> _deleteHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("history_data") ?? [];

    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await prefs.setStringList("history_data", data);
    }

    if (!context.mounted) return;

    Navigator.pop(
      context,
      {'deleted': true},
    );
  }

  Future<void> _downloadJpg(BuildContext context) async {
    try {
      final screenWidth = MediaQuery.of(context).size.width;

      final Widget downloadWidget = InheritedTheme.captureAll(
        context,
        Material(
          color: const Color(0xFFF5F6F8),
          child: SizedBox(
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildResultCard(),
                  const SizedBox(height: 14),
                  _buildInputCard(),
                  const SizedBox(height: 14),
                  _buildCalculationCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );

      final Uint8List pngBytes =
          await screenshotController.captureFromLongWidget(
        downloadWidget,
        context: context,
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 300),
      );

      final decoded = img.decodePng(pngBytes);

      if (decoded == null) {
        throw Exception('Gagal mengubah gambar.');
      }

      final jpgBytes = img.encodeJpg(
        decoded,
        quality: 95,
      );

      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin galeri diperlukan untuk menyimpan gambar.',
              ),
            ),
          );

          return;
        }
      }

      final fileName =
          'hasil_emas_fisik_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Gal.putImageBytes(
        Uint8List.fromList(jpgBytes),
        name: fileName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil perhitungan berhasil disimpan ke galeri.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan gambar: $e',
          ),
        ),
      );
    }
  }

  void _hitungUlang(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PhysicalGoldPage(
            initialData: detail,
          );
        },
      ),
    );
  }

  Widget _buildResultCard() {
    final step5 = _number(detail['step5']);
    final date = item['date']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -20,
            right: -30,
            top: -5,
            bottom: -5,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.60,
                child: Image.asset(
                  'assets/images/ewf.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'HASIL PERHITUNGAN',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                  color: Color.fromARGB(255, 90, 90, 90),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isProfit
                      ? const Color(0xFFDDF4DF)
                      : const Color(0xFFFFDDDD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatRupiah(step5),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 132, 0),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                date,
                style: const TextStyle(
                  color: Color.fromARGB(255, 27, 27, 27),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return _card(
      title: 'INPUT PERHITUNGAN',
      child: Column(
        children: [
          _row(
            'Modal Awal',
            _formatRupiah(detail['modal']),
          ),
          _divider(),
          _row(
            'Kurs',
            'Rp ${_formatNumber(detail['kurs'])}',
          ),
          _divider(),
          _row(
            'Harga Beli',
            _formatRupiah(detail['hargaBeli']),
          ),
          _divider(),
          _row(
            'Harga Jual',
            _formatRupiah(detail['hargaJual']),
          ),
          _divider(),
          _row(
            'TOz',
            _formatToz(31.1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard() {
    return _card(
      title: 'RINCIAN PERHITUNGAN',
      child: Column(
        children: [
          _stepRow(
            '1',
            'Harga Beli per TOz',
            'Harga Beli × Kurs ÷ 31,1',
            _formatRupiah(detail['step1']),
          ),
          _stepRow(
            '2',
            'Harga Jual per TOz',
            'Harga Jual × Kurs ÷ 31,1',
            _formatRupiah(detail['step2']),
          ),
          _stepRow(
            '3',
            'Selisih Harga',
            'Step 2 − Step 1',
            _formatRupiah(detail['step3']),
          ),
          _stepRow(
            '4',
            'Jumlah Emas',
            'Modal ÷ Step 1',
            '${_formatToz(detail['step4'])} TOz',
          ),
          _stepRow(
            '5',
            'Profit / Loss',
            'Step 3 × Step 4',
            _formatRupiah(detail['step5']),
            isFinal: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFF7931E),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Emas Fisik',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResultCard(),
            const SizedBox(height: 14),
            _buildInputCard(),
            const SizedBox(height: 14),
            _buildCalculationCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        _deleteHistory(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'HAPUS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        _hitungUlang(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'HITUNG ULANG',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  _downloadJpg(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF555555),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'DOWNLOAD JPG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Color(0xFFF7931E),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFF7931E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(
    String number,
    String title,
    String formula,
    String value, {
    bool isFinal = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isFinal
            ? const Color(0xFFFFF1DD)
            : const Color(0xFFFFFCFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFinal
              ? const Color(0xFFF7931E)
              : const Color(0xFFE3D7CD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF7931E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFinal
                        ? const Color(0xFFE47700)
                        : const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: isFinal
                          ? const Color(0xFFE47700)
                          : const Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE8E8E8),
    );
  }
}