import 'package:flutter/material.dart';

class HistoryDetailEmasPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const HistoryDetailEmasPage({super.key, required this.item});

  Map<String, dynamic> get detail => item['detail'] ?? {};

  /// ======================
  /// LOGIC BUY / SELL
  /// ======================
  bool get isProfit {
    final result = item['result']?.toString() ?? '';
    return result.contains('+') || result.contains('untung');
  }

  @override
  Widget build(BuildContext context) {
    final date = item['date'] as DateTime?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Detail Emas Fisik",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          /// BACKGROUND
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
                /// CARD HASIL
                /// ======================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 🔥 WATERMARK FIX (CENTER + LEBIH KELIHATAN)
                      Positioned.fill(
                        child: Center(
                          child: Opacity(
                            opacity: 0.12, // ⬅️ lebih jelas tapi aman
                            child: Image.asset(
                              'assets/images/ewf.png',
                              width: 180, // ⬅️ diperbesar biar kelihatan
                              fit: BoxFit.contain,
                              color: Colors.grey.withOpacity(0.25), // ⬅️ biar kontras
                              colorBlendMode: BlendMode.srcATop,
                            ),
                          ),
                        ),
                      ),

                      /// 🔥 CONTENT
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "HASIL PERHITUNGAN",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),

                          Icon(
                            isProfit ? Icons.trending_up : Icons.trending_down,
                            color: isProfit ? Colors.green : Colors.red,
                            size: 30,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            isProfit ? "PROFIT" : "LOSS",
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            item['result'] ?? "-",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "${_formatDate(date)} • ${item['time'] ?? ''} WIB",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ======================
                /// RINCIAN
                /// ======================
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RINCIAN PERHITUNGAN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF7931E),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _row("Modal Awal", _rp(detail['modal'])),
                      _divider(),
                      _row("Harga Beli", _rp(detail['hb'])),
                      _divider(),
                      _row("Harga Jual", _rp(detail['hj'])),
                      _divider(),
                      _row("Kurs", detail['kurs']?.toString() ?? "-"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ======================
                /// BUTTON
                /// ======================
                _button("HITUNG ULANG", () {
                  Navigator.pushNamed(
                    context,
                    '/calculator',
                    arguments: detail,
                  );
                }),

                const SizedBox(height: 10),

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
  /// COMPONENT
  /// ======================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFFF7931E)),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 16);

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

  String _rp(dynamic v) {
    if (v == null) return "-";
    return "Rp ${v.toString()}";
  }

  /// ======================
  /// FORMAT TANGGAL INDONESIA
  /// ======================
  String _formatDate(DateTime? d) {
    if (d == null) return "-";

    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return "${d.day} ${months[d.month]} ${d.year}";
  }
}