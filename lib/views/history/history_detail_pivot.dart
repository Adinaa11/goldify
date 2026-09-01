import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final detail =
        Map<String, dynamic>.from(widget.item['detail'] ?? {});

    final pp = detail['pp'];

    final r1 = detail['r1'];
    final r2 = detail['r2'];
    final r3 = detail['r3'];
    final r4 = detail['r4'];

    final s1 = detail['s1'];
    final s2 = detail['s2'];
    final s3 = detail['s3'];
    final s4 = detail['s4'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pivot Point"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// BACKGROUND LOGO
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/ewf.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ======================
                /// PIVOT POINT
                /// ======================
                _card(
                  child: Column(
                    children: [
                      const Text("PIVOT POINT"),
                      const SizedBox(height: 6),
                      Text(
                        "${pp ?? '-'}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ======================
                /// RESISTANCE
                /// ======================
                _levelCard("Resistance", [r1, r2, r3, r4], Colors.green),

                const SizedBox(height: 12),

                /// ======================
                /// SUPPORT
                /// ======================
                _levelCard("Support", [s1, s2, s3, s4], Colors.red),

                const SizedBox(height: 16),

                /// ======================
                /// TOGGLE DETAIL
                /// ======================
                GestureDetector(
                  onTap: () =>
                      setState(() => showDetail = !showDetail),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showDetail
                            ? "Sembunyikan Detail"
                            : "Lihat Detail",
                        style: const TextStyle(
                          color: Color(0xFFF7931E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(showDetail
                          ? Icons.expand_less
                          : Icons.expand_more),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// ======================
                /// MIDPOINT
                /// ======================
                if (showDetail)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MIDPOINT",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        _row("R4 - R3", _mid(r4, r3)),
                        _row("R3 - R2", _mid(r3, r2)),
                        _row("R2 - R1", _mid(r2, r1)),
                        _row("R1 - PP", _mid(r1, pp)),
                        _row("PP - S1", _mid(pp, s1)),
                        _row("S1 - S2", _mid(s1, s2)),
                        _row("S2 - S3", _mid(s2, s3)),
                        _row("S3 - S4", _mid(s3, s4)),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                /// ======================
                /// HITUNG ULANG
                /// ======================
                _button(
                  "HITUNG ULANG",
                  () {
                    Navigator.pushNamed(
                      context,
                      '/calculator_pivot',
                      arguments: detail,
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// ======================
                /// HAPUS
                /// ======================
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
    );
  }

  /// ======================
  /// UI COMPONENT
  /// ======================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _button(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF7931E),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _levelCard(String title, List levels, Color color) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 10),
          ...levels.asMap().entries.map((e) {
            return _row("${title[0]}${e.key + 1}", e.value);
          }),
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  String _mid(dynamic a, dynamic b) {
    if (a == null || b == null) return "-";

    final double da = double.tryParse(a.toString()) ?? 0;
    final double db = double.tryParse(b.toString()) ?? 0;

    return ((da + db) / 2).toStringAsFixed(2);
  }
}