// lib/views/history/history_detail.dart
import 'package:flutter/material.dart';
import 'history_utils.dart';

class HistoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const HistoryDetailPage({super.key, required this.item});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  bool _deleting = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final String type = (item['type'] ?? '').toString();
    final bool isPivot = type.toLowerCase().contains('pivot');
    final String result = item['result']?.toString() ?? '';
    final bool isProfit = result.startsWith('+');

    const orange = Color(0xFFF7931E);
    const green = Color(0xFF16A34A);
    const red = Color(0xFFDC2626);

    // sample input / pivot values if not present in item
    final Map<String, String> inputData = item['input'] as Map<String, String>? ?? {
      'High': item['high']?.toString() ?? item['detail']?['High']?.toString() ?? '4430',
      'Low': item['low']?.toString() ?? item['detail']?['Low']?.toString() ?? '4420',
      'Close': item['close']?.toString() ?? item['detail']?['Close']?.toString() ?? '4450',
    };

    final Map<String, String> pivotLevels = (item['pivot'] as Map<String, String>?) ?? {
      'R4': '4463',
      'R3': '4453',
      'R2': '4443',
      'R1': '4447',
      'PP': item['result']?.replaceAll('+', '').replaceAll('-', '') ?? '4433',
      'S1': '4437',
      'S2': '4423',
      'S3': '4413',
      'S4': '4403',
    };

    final Map<String, String> emasDetail = (item['detail'] as Map<String, String>?) ?? {
      'Modal Awal': 'Rp 4.850.000',
      'Kurs (USD)': 'Rp 15.200',
      'Harga Beli / gr': 'Rp 970.000',
      'Harga Jual / gr': 'Rp 1.000.000',
      'Tanggal Hitung': HistoryUtils.formatShortDate(item['date'] as DateTime),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(item['title'] ?? 'Detail Perhitungan', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---------- Header: Hasil (big) ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Icon(isPivot ? Icons.show_chart : Icons.calculate, color: orange),
                    const SizedBox(width: 8),
                    const Text('Hasil Perhitungan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 12),
                Text(isPivot ? 'HASIL PIVOT POINT' : 'HASIL', style: const TextStyle(letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(isProfit ? Icons.arrow_upward : Icons.arrow_downward, color: isProfit ? green : red),
                  const SizedBox(width: 6),
                  Text(
                    pivotLevels['PP'] ?? result.replaceAll('+', '').replaceAll('-', ''),
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: orange),
                  ),
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text(isPivot ? 'Pivot Point Terhitung' : 'Perhitungan Selesai', style: const TextStyle(color: Colors.grey)),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ---------- Data Input ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Data Input', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _inputColumn('High', inputData['High'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _inputColumn('Low', inputData['Low'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _inputColumn('Close', inputData['Close'] ?? '-')),
                  ],
                ),
              ]),
            ),

            const SizedBox(height: 18),

            // ---------- Rincian Level Pivot (if pivot) ----------
            if (isPivot) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.12)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: const [
                    Icon(Icons.trending_up, color: Color(0xFFF7931E), size: 18),
                    SizedBox(width: 8),
                    Text('Rincian Level Pivot', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),

                  // Resistance list (R4..R1) as tiles
                  _levelListTile('R4', pivotLevels['R4'] ?? '-', showTopRadius: true),
                  const SizedBox(height: 6),
                  _levelListTile('R3', pivotLevels['R3'] ?? '-'),
                  const SizedBox(height: 6),
                  _levelListTile('R2', pivotLevels['R2'] ?? '-'),
                  const SizedBox(height: 6),
                  _levelListTile('R1', pivotLevels['R1'] ?? '-', showBottomRadius: true),

                  const SizedBox(height: 12),

                  // Pivot box emphasized
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: orange.withOpacity(0.2)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('PIVOT POINT (PP)', style: TextStyle(letterSpacing: 0.6, fontWeight: FontWeight.bold)),
                      Text(pivotLevels['PP'] ?? '-', style: const TextStyle(color: Color(0xFFF7931E), fontWeight: FontWeight.bold)),
                    ]),
                  ),

                  const SizedBox(height: 12),

                  // Support list
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: const [
                        Icon(Icons.trending_down, color: Color(0xFF6B7280), size: 16),
                        SizedBox(width: 8),
                        Text('SUPPORT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 8),
                      _levelListTile('S1', pivotLevels['S1'] ?? '-', showTopRadius: true),
                      const SizedBox(height: 6),
                      _levelListTile('S2', pivotLevels['S2'] ?? '-'),
                      const SizedBox(height: 6),
                      _levelListTile('S3', pivotLevels['S3'] ?? '-'),
                      const SizedBox(height: 6),
                      _levelListTile('S4', pivotLevels['S4'] ?? '-', showBottomRadius: true),
                    ]),
                  ),

                  const SizedBox(height: 8),

                  // expand / collapse details button
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(_expanded ? 'Sembunyikan Detail' : 'Lihat Detail', style: TextStyle(color: orange, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: orange),
                    ]),
                  ),

                  if (_expanded) ...[
                    const SizedBox(height: 12),
                    // extra details: show small table or explanation
                    Text('Rincian perhitungan pivot dan formula ditampilkan di sini jika tersedia.', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ]),
              ),
            ] else ...[
              // ---------- Emas Fisik: ringkasan 5 tahapan ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Rincian Perhitungan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...emasDetail.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(e.key, style: const TextStyle(color: Colors.grey)),
                      Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  )),
                ]),
              ),
            ],

            const SizedBox(height: 18),

            // ---------- Buttons ----------
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // send signal to parent to recalculate
                    Navigator.pop(context, {'recalculate': true, 'item': item});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: orange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Hitung Ulang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleting ? null : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Riwayat'),
                        content: const Text('Yakin ingin menghapus riwayat ini?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      setState(() => _deleting = true);
                      // simulate delete op (if you have DB, do it here)
                      await Future.delayed(const Duration(milliseconds: 300));
                      Navigator.pop(context, {'deleted': true, 'item': item});
                    }
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.white),
                  child: _deleting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Hapus Riwayat', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),

            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  // small helper widgets -------------------------------------------------
  Widget _inputColumn(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  Widget _levelListTile(String title, String value, {bool showTopRadius = false, bool showBottomRadius = false}) {
    final borderRadius = BorderRadius.vertical(
      top: showTopRadius ? const Radius.circular(8) : Radius.zero,
      bottom: showBottomRadius ? const Radius.circular(8) : Radius.zero,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius, border: Border.all(color: Colors.grey.shade200)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
    );
  }
}