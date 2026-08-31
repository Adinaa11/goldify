import 'package:flutter/material.dart';
import 'history_utils.dart';
import 'history_detail.dart';

class HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  // terima callback async dari parent (HistoryPage)
  final Future<void> Function(Map<String, dynamic> item)? onTap;

  const HistoryItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String result = item['result']?.toString() ?? '';
    final bool isProfit = result.startsWith('+');

    // colors
    const greenColor = Color(0xFF16A34A);
    const redColor = Color(0xFFDC2626);
    const orangeColor = Color(0xFFF7931E);
    final shadowColor = Color.fromRGBO(0, 0, 0, 0.04);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (onTap != null) {
          // jika parent memberi handler async, panggil dan await
          await onTap!(item);
        } else {
          // fallback: langsung navigasi ke detail sendiri
          final res = await Navigator.push<Map<String, dynamic>?>(
            context,
            MaterialPageRoute(builder: (_) => HistoryDetailPage(item: item)),
          );

          if (res != null && res['deleted'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat dihapus')));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  ((item['type'] ?? '') as String).toLowerCase().contains('pivot') ? Icons.show_chart : Icons.calculate,
                  color: orangeColor,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(HistoryUtils.formatShortDate(item['date'] as DateTime),
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text('• ${item['time'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  if (item['subtitle'] != null) ...[
                    const SizedBox(height: 8),
                    Text(item['subtitle'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // result + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14, color: isProfit ? greenColor : redColor),
                    const SizedBox(width: 6),
                    Text(result,
                        style: TextStyle(color: isProfit ? greenColor : redColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}