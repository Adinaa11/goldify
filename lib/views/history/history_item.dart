import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onTap;

  const HistoryItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit =
        (item['result']?.toString() ?? '').startsWith('+');

    return GestureDetector(
      onTap: () => onTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calculate, color: Colors.orange),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['time']),
                ],
              ),
            ),

            Text(
              item['result'],
              style: TextStyle(
                color: isProfit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }
}