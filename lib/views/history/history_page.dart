import 'package:flutter/material.dart';
import 'history_list.dart';
import 'history_empty.dart';
import 'history_filter.dart';
import 'history_detail_emas.dart';
import 'history_detail_pivot.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;
  const HistoryPage({super.key, this.onBack});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedChip = "Semua";

  /// ======================
  /// ✅ DUMMY DATA (BIAR MUNCUL LIST)
  /// ======================
  List<Map<String, dynamic>> historyData = [
    {
      "type": "Emas Fisik",
      "title": "Kalkulator Emas",
      "date": DateTime.now(),
      "time": "10:30",
      "result": "+150.000",
      "detail": {
        "modal": 4850000,
        "hb": 970000,
        "hj": 1000000,
        "kurs": 15200,
      }
    },
    {
      "type": "Pivot Point",
      "title": "Pivot Point",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "time": "16:45",
      "result": "-25.000",
      "detail": {
        "pp": 4433,
        "r1": 4447,
        "r2": 4453,
        "r3": 4460,
        "r4": 4465,
        "s1": 4437,
        "s2": 4423,
        "s3": 4413,
        "s4": 4403,
      }
    }
  ];

  /// ======================
  /// FILTER
  /// ======================
  List<Map<String, dynamic>> get filteredData {
    if (selectedChip == "Semua") return historyData;
    return historyData.where((e) => e['type'] == selectedChip).toList();
  }

  /// ======================
  /// NAVIGASI DETAIL
  /// ======================
  Future<void> _onItemTap(Map<String, dynamic> item) async {
    Widget page;

    if ((item['type']).toLowerCase().contains('emas')) {
      page = HistoryDetailEmasPage(item: item);
    } else {
      page = HistoryDetailPivotPage(item: item);
    }

    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (!mounted) return;

    /// DELETE HISTORY
    if (res != null && res['deleted'] == true) {
      setState(() => historyData.remove(item));
    }
  }

  /// ======================
  /// CHIP UI
  /// ======================
  Widget _chip(String label) {
    final active = selectedChip == label;

    return GestureDetector(
      onTap: () => setState(() => selectedChip = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF7931E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    widget.onBack != null
        ? widget.onBack!()
        : Navigator.pop(context);
  }

  /// ======================
  /// UI
  /// ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Riwayat Perhitungan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBack,
        ),
      ),

      body: Column(
        children: [
          /// ======================
          /// FILTER + CHIP
          /// ======================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _chip("Semua"),
                _chip("Emas Fisik"),
                _chip("Pivot Point"),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => const HistoryFilter(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, size: 18),
                  ),
                )
              ],
            ),
          ),

          /// ======================
          /// CONTENT
          /// ======================
          Expanded(
            child: filteredData.isEmpty
                ? HistoryEmpty(onStart: _handleBack)
                : HistoryList(
                    data: filteredData,
                    onItemTap: _onItemTap,
                  ),
          )
        ],
      ),
    );
  }
}