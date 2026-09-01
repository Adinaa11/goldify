import 'package:flutter/material.dart';
import 'history_item.dart';

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>) onItemTap;

  const HistoryList({
    super.key,
    required this.data,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (_, i) {
        return HistoryItem(
          item: data[i],
          onTap: onItemTap,
        );
      },
    );
  }
}