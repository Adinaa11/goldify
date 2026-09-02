import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';

class HistoryDetailPivotPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const HistoryDetailPivotPage({super.key, required this.item});

  @override
  State<HistoryDetailPivotPage> createState() =>
      _HistoryDetailPivotPageState();
}

class _HistoryDetailPivotPageState
    extends State<HistoryDetailPivotPage> {
  bool showDetail = false;

  final ScreenshotController screenshotController =
      ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final d =
        Map<String, dynamic>.from(widget.item['detail'] ?? {});
    final date = widget.item['date'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Riwayat Pivot Point"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      /// 🔥 FIX WATERMARK DI DALAM CONTENT
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          alignment: Alignment.center,
          children: [

            /// 🔥 WATERMARK BESAR (DI DALAM CONTENT)
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: -0.2, // 🔥 biar lebih aesthetic (miring dikit)
                  child: Opacity(
                    opacity: 0.18, // 🔥 lebih kelihatan (0.15 - 0.25)
                    child: Image.asset(
                      'assets/images/ewf.png',
                      width: 420, // 🔥 BESAR BANGET biar kelihatan di download
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            /// 🔥 CONTENT
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// ======================
                  /// HASIL PIVOT
                  /// ======================
                  _card(
                    child: Column(
                      children: [
                        const Text(
                          "HASIL PIVOT POINT",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          d['pp']?.toString() ?? "-",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF7931E),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ======================
                  /// DATA INPUT
                  /// ======================
                  _card(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _dataItem("High", d['high']),
                        _dataItem("Low", d['low']),
                        _dataItem("Close", d['close']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ======================
                  /// RESISTANCE
                  /// ======================
                  _sectionTitle("RESISTANCE"),

                  _level("R4", d['r4']),
                  if (showDetail)
                    _mid("Midpoint R4 - R3",
                        _calcMid(d['r4'], d['r3'])),

                  _level("R3", d['r3']),
                  if (showDetail)
                    _mid("Midpoint R3 - R2",
                        _calcMid(d['r3'], d['r2'])),

                  _level("R2", d['r2']),
                  if (showDetail)
                    _mid("Midpoint R2 - R1",
                        _calcMid(d['r2'], d['r1'])),

                  _level("R1", d['r1']),
                  if (showDetail)
                    _mid("Midpoint R1 - PP",
                        _calcMid(d['r1'], d['pp'])),

                  const SizedBox(height: 12),

                  /// ======================
                  /// PIVOT POINT
                  /// ======================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7931E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PIVOT POINT (PP)",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          d['pp']?.toString() ?? "-",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ======================
                  /// SUPPORT
                  /// ======================
                  _sectionTitle("SUPPORT"),

                  _level("S1", d['s1']),
                  if (showDetail)
                    _mid("Midpoint PP - S1",
                        _calcMid(d['pp'], d['s1'])),

                  _level("S2", d['s2']),
                  if (showDetail)
                    _mid("Midpoint S1 - S2",
                        _calcMid(d['s1'], d['s2'])),

                  _level("S3", d['s3']),
                  if (showDetail)
                    _mid("Midpoint S2 - S3",
                        _calcMid(d['s2'], d['s3'])),

                  _level("S4", d['s4']),
                  if (showDetail)
                    _mid("Midpoint S3 - S4",
                        _calcMid(d['s3'], d['s4'])),

                  const SizedBox(height: 16),

                  /// TOGGLE DETAIL
                  GestureDetector(
                    onTap: () =>
                        setState(() => showDetail = !showDetail),
                    child: Text(
                      showDetail
                          ? "Sembunyikan Detail"
                          : "Lihat Detail",
                      style: const TextStyle(
                        color: Color(0xFFF7931E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// HITUNG ULANG
                  _button("HITUNG ULANG", () {
                    Navigator.pushNamed(
                      context,
                      '/calculator_pivot',
                      arguments: d,
                    );
                  }),

                  const SizedBox(height: 10),

                  /// DOWNLOAD
                  _button("DOWNLOAD HASIL", _download),

                  const SizedBox(height: 10),

                  /// HAPUS
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, {"deleted": true});
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("HAPUS RIWAYAT"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _dataItem(String title, dynamic value) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFF7931E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _level(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value?.toString() ?? "-",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _mid(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value),
        ],
      ),
    );
  }

  Widget _button(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF7931E),
        ),
        child: Text(text),
      ),
    );
  }

  String _calcMid(dynamic a, dynamic b) {
    if (a == null || b == null) return "-";
    final da = double.tryParse(a.toString()) ?? 0;
    final db = double.tryParse(b.toString()) ?? 0;
    return ((da + db) / 2).toStringAsFixed(2);
  }

  String _formatDate(dynamic d) {
    if (d == null) return "-";
    if (d is DateTime) {
      return "${d.day} ${_month(d.month)} ${d.year}";
    }
    return d.toString();
  }

  String _month(int m) {
    const months = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return months[m - 1];
  }

  Future<void> _download() async {
    final Uint8List? image =
        await screenshotController.capture();
    if (image == null) return;

    await Gal.putImageBytes(image);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Berhasil disimpan ke galeri"),
      ),
    );
  }
}