import 'package:flutter/material.dart';
import 'history_detail_pivot.dart';
import 'history_detail_emas.dart';
import 'history_detail_hangseng.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryPage({
    super.key,
    this.onBack,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color orange = Color(0xFFF7931E);
  static const Color background = Color(0xFFF5F6F8);

  List<Map<String, dynamic>> history = [];
  String selectedFilter = "Semua";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final response = await supabase
          .from('history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        history = List<Map<String, dynamic>>.from(response);
      });

    } catch (e) {
      debugPrint('Error load history: $e');
    }
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == "Semua") {
      return history;
    }

    return history.where((e) {
      final type =
          e['type']?.toString().toLowerCase() ?? '';

      if (selectedFilter == "Pivot") {
        return type.contains("pivot");
      }

      if (selectedFilter == "Hangseng") {
        return type.contains("hangseng") ||
            type.contains("hsi");
      }

      if (selectedFilter == "Emas Fisik") {
        return type.contains("emas");
      }

      return true;
    }).toList();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );

    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String _monthName(int month) {
    const months = [
      'JANUARI',
      'FEBRUARI',
      'MARET',
      'APRIL',
      'MEI',
      'JUNI',
      'JULI',
      'AGUSTUS',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DESEMBER',
    ];

    if (month < 1 || month > 12) {
      return '-';
    }

    return months[month - 1];
  }

  String _dateHeader(DateTime date) {
    if (_isToday(date)) {
      return 'HARI INI';
    }

    if (_isYesterday(date)) {
      return 'KEMARIN';
    }

    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _dateKey(Map<String, dynamic> item) {
    final date = _parseDate(item['created_at']);

    if (date == null) {
      return 'LAINNYA';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<MapEntry<String, List<Map<String, dynamic>>>>
      get groupedHistory {
    final groups =
        <String, List<Map<String, dynamic>>>{};

    for (final item in filteredHistory) {
      final key = _dateKey(item);

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item);
    }

    for (final group in groups.values) {
      group.sort((a, b) {
        final dateA = _parseDate(a['created_at']);
        final dateB = _parseDate(b['created_at']);

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });
    }

    final entries = groups.entries.toList();

    entries.sort((a, b) {
      final dateA =
          _parseDate(a.value.first['created_at']);

      final dateB =
          _parseDate(b.value.first['created_at']);

      if (dateA == null && dateB == null) {
        return 0;
      }

      if (dateA == null) {
        return 1;
      }

      if (dateB == null) {
        return -1;
      }

      return dateB.compareTo(dateA);
    });

    return entries;
  }

  void _openDetail(Map<String, dynamic> item) {
    final type =
        item['type']?.toString().toLowerCase() ?? '';

    final rawIndex =
        item['_historyRawIndex'] as int?;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (type.contains("pivot")) {
            return HistoryDetailPivotPage(
              item: item,
              index: rawIndex ?? -1,
            );
          }

          if (type.contains("hangseng") ||
              type.contains("hsi")) {
            return HistoryDetailHangsengPage(
              item: item,
              index: rawIndex ?? -1,
            );
          }

          return HistoryDetailEmasPage(
            item: item,
            index: rawIndex ?? -1,
          );
        },
      ),
    ).then((_) {
      _loadHistory();
    });
  }

  String _formatRupiah(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '') ?? 0;

    final text =
        number.truncate().abs().toString();

    String result = "";

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        result += ".";
      }

      result += text[i];
    }

    return result;
  }

  String _formatPivot(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '');

    if (number == null) {
      return '-';
    }

    return number
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupedHistory;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(
          alpha: 0.15,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: orange,
            size: 21,
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        titleSpacing: 0,
        title: const Text(
          "Daftar Perhitungan Anda",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(
            child: groups.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      16,
                    ),
                    itemCount: groups.fold<int>(
                      0,
                      (total, group) =>
                          total +
                          1 +
                          group.value.length,
                    ),
                    itemBuilder: (context, index) {
                      int currentIndex = 0;

                      for (final group in groups) {
                        if (index == currentIndex) {
                          final date =
                              _parseDate(
                            group.value.first['created_at'],
                          );

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 12,
                              bottom: 4,
                            ),
                            child: Text(
                              date == null
                                  ? 'LAINNYA'
                                  : _dateHeader(date),
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                    Color(0xFF555555),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        currentIndex++;

                        if (index <
                            currentIndex +
                                group.value.length) {
                          final itemIndex =
                              index - currentIndex;

                          return _buildHistoryCard(
                            group.value[itemIndex],
                          );
                        }

                        currentIndex +=
                            group.value.length;
                      }

                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    final list = [
      "Semua",
      "Pivot",
      "Hangseng",
      "Emas Fisik",
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10,
      ),
      child: Row(
        children: list.map((e) {
          final active =
              selectedFilter == e;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = e;
                });
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? orange
                      : Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 11,
                      color: active
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 60,
            color: orange,
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum Ada Riwayat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildHistoryCard(
    Map<String, dynamic> item,
  ) {
    final resultData =
        Map<String, dynamic>.from(item['result'] ?? {});

    final resultText =
        resultData['status']?.toString() ?? '';

    final amount = resultData['step5'] ?? 0;

    final bool profit =
        resultText.toLowerCase().contains("profit");

    final type =
        item['type']?.toString().toLowerCase() ?? '';

    final bool pivot = type.contains("pivot");

    final bool hangseng =
        type.contains("hangseng") ||
        type.contains("hsi");

    return GestureDetector(
      onTap: () {
        _openDetail(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE4E4E4),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Icon(
                    pivot
                        ? Icons.analytics_outlined
                        : hangseng
                            ? Icons.trending_up
                            : Icons.calculate_outlined,
                    color: orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        pivot
                            ? "Pivot Point"
                            : hangseng
                                ? "Hangseng"
                                : "Emas Fisik",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        _formatDateTime(
                            item['created_at']),
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                              Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              height: 1,
              color: const Color(0xFFE8E8E8),
            ),
            const SizedBox(height: 10),

            const Text(
              "Hasil Perhitungan",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: Text(
                    pivot
                        ? "Pivot : ${_formatPivot(resultData['pivot'] ?? resultData['pp'])}"
                        : hangseng
                            ? "PP : ${_formatPivot(resultData['pp'])}"
                            : "$resultText : Rp ${_formatRupiah(amount)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color: pivot || hangseng
                          ? orange
                          : profit
                              ? orange
                              : Colors.red,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF777777),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _formatDateTime(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      return "${date.day.toString().padLeft(2, '0')}/"
            "${date.month.toString().padLeft(2, '0')}/"
            "${date.year} "
            "${date.hour.toString().padLeft(2, '0')}:"
            "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return value.toString();
    }
  }
}