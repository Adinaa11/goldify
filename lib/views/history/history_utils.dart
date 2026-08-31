class HistoryUtils {
  static String getLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) return 'Hari Ini';
    if (d == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  static String formatShortDate(DateTime dt) {
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  static String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return names[m-1];
  }
}