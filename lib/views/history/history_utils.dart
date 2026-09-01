import 'package:flutter/material.dart';
import 'history_detail_emas.dart';
import 'history_detail_pivot.dart';

class HistoryUtils {

  static String getLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);

    if (date == today) return 'Hari Ini';
    if (date == today.subtract(const Duration(days: 1))) return 'Kemarin';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String headerLabelFor(DateTime now) {
    final today = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final t = DateTime(today.year, today.month, today.day);

    if (date == t) return 'HARI INI';
    if (date == t.subtract(const Duration(days: 1))) return 'KEMARIN';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatShortDate(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  // ✅ FIX UTAMA DI SINI
  static Widget buildDetailPage(BuildContext context, Map<String, dynamic> item) {
    final type = (item['type'] ?? '').toString().toLowerCase();

    if (type.contains('pivot')) {
      return HistoryDetailPivotPage(item: item);
    } else {
      return HistoryDetailEmasPage(item: item);
    }
  }
}