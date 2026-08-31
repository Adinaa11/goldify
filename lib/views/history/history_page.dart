import 'package:flutter/material.dart';
import 'history_list.dart';
import 'history_empty.dart';
import 'history_filter.dart';
import 'history_utils.dart';
import 'history_detail.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;
  const HistoryPage({super.key, this.onBack});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // SAMPLE DATA (replace with DB/API later)
  List<Map<String, dynamic>> historyData = [
    {
      "title": "Kalkulator Emas",
      "type": "Emas Fisik",
      "result": "+150.000",
      "date": DateTime.now(),
      "time": "10:30",
      "subtitle": "Hasil Perhitungan"
    },
    {
      "title": "Pivot Point",
      "type": "Pivot Point",
      "result": "-25.000",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "time": "16:45",
      "subtitle": "Level Resistensi 1"
    },
  ];

  // UI state
  String selectedChip = "Semua";

  // filters from bottom sheet
  DateTime? _filterFrom;
  DateTime? _filterTo;
  String _filterStatus = 'All';
  String _filterType = 'All';

  // prevent opening multiple filter modal
  bool _isFilterOpen = false;

  // Combined filtered data
  List<Map<String, dynamic>> get filteredData {
    var list = List<Map<String, dynamic>>.from(historyData);

    // chip filter (quick)
    if (selectedChip != "Semua") {
      list = list.where((e) => e['type'] == selectedChip).toList();
    }

    // bottom-sheet type filter (if user set)
    if (_filterType != 'All') {
      list = list.where((e) => e['type'] == _filterType).toList();
    }

    // status filter
    if (_filterStatus == 'Profit') {
      list = list.where((e) => (e['result']?.toString() ?? '').startsWith('+')).toList();
    } else if (_filterStatus == 'Loss') {
      list = list.where((e) => (e['result']?.toString() ?? '').startsWith('-')).toList();
    }

    // date range filter (inclusive)
    if (_filterFrom != null || _filterTo != null) {
      list = list.where((e) {
        final DateTime d = e['date'] as DateTime;
        if (_filterFrom != null) {
          final from = DateTime(_filterFrom!.year, _filterFrom!.month, _filterFrom!.day);
          if (d.isBefore(from)) return false;
        }
        if (_filterTo != null) {
          final to = DateTime(_filterTo!.year, _filterTo!.month, _filterTo!.day, 23, 59, 59);
          if (d.isAfter(to)) return false;
        }
        return true;
      }).toList();
    }

    // newest first
    list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return list;
  }

  // Open bottom sheet only once at a time
  Future<void> _openFilterSheet() async {
    if (_isFilterOpen) return;
    _isFilterOpen = true;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const HistoryFilter(),
    );

    _isFilterOpen = false;

    if (result != null) {
      setState(() {
        _filterFrom = result['from'] as DateTime?;
        _filterTo = result['to'] as DateTime?;
        _filterStatus = (result['status'] as String?) ?? 'All';
        _filterType = (result['type'] as String?) ?? 'All';

        // if user picked a specific type in the filter, reflect it on chips
        if (_filterType != 'All') {
          selectedChip = _filterType;
        }
      });
    }
  }

  // Handle tap on an item: push detail and handle returned result
  Future<void> _onItemTap(Map<String, dynamic> item) async {
    final res = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailPage(item: item)),
    );

    if (res == null) return;

    if (res['deleted'] == true) {
      setState(() {
        historyData.removeWhere((e) =>
            e['title'] == item['title'] &&
            (e['date'] as DateTime).isAtSameMomentAs(item['date'] as DateTime) &&
            e['time'] == item['time']);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat dihapus')));
      return;
    }

    if (res['recalculate'] == true) {
      // implement redirect to calculator with item['detail'] if you have a calculator screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hitung ulang dipilih — implementasikan navigasi ke kalkulator')));
    }
  }

  // Chip builder
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
          border: Border.all(color: active ? const Color(0xFFF7931E) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Back handling: call onBack if provided (useful if parent controls bottom-nav),
  // otherwise just pop the route.
  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _handleBack),
        title: const Text('Riwayat Perhitungan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        // no duplicate filter icon here — filter is the single pill next to chips
      ),
      body: Column(
        children: [
          // chips row + single filter pill at the right
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _chip("Semua"),
                _chip("Emas Fisik"),
                _chip("Pivot Point"),
                const Spacer(),

                // SINGLE filter pill (next to chips)
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, size: 16, color: Color(0xFFF7931E)),
                        SizedBox(width: 6),
                        Text("Filter", style: TextStyle(color: Color(0xFFF7931E), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // small header
          Container(
            width: double.infinity,
            color: const Color(0xFFF5F6F8),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Daftar Perhitungan Anda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 4),
                Text('HARI INI', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: filteredData.isEmpty
                  ? HistoryEmpty(onStart: () {
                      // when pressing "Mulai Menghitung" from empty state, go back (or call parent)
                      _handleBack();
                    })
                  : HistoryList(data: filteredData, onItemTap: _onItemTap),
            ),
          ),
        ],
      ),
    );
  }
}