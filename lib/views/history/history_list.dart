import 'package:flutter/material.dart';
import 'history_item.dart';
import 'history_utils.dart';

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  // callback async dari parent (HistoryPage)
  final Future<void> Function(Map<String, dynamic> item)? onItemTap;

  const HistoryList({
    super.key,
    required this.data,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group items by date label
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in data) {
      final label = HistoryUtils.getLabel(item['date'] as DateTime);
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(item);
    }

    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: entries.length,
      itemBuilder: (context, idx) {
        final label = entries[idx].key;
        final items = entries[idx].value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            // teruskan callback onItemTap ke setiap HistoryItem
            ...items.map((it) => HistoryItem(item: it, onTap: onItemTap)).toList(),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}