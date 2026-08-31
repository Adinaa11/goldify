import 'package:flutter/material.dart';

class HistoryFilter extends StatefulWidget {
  const HistoryFilter({super.key});

  @override
  State<HistoryFilter> createState() => _HistoryFilterState();
}

class _HistoryFilterState extends State<HistoryFilter> {
  DateTime? _from;
  DateTime? _to;
  String _status = 'All'; // 'All' | 'Profit' | 'Loss'
  String _type = 'All'; // 'All' | 'Emas Fisik' | 'Pivot Point'

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate(BuildContext ctx, bool isFrom) async {
    final now = DateTime.now();
    final initial = isFrom ? (_from ?? now) : (_to ?? now);
    final picked = await showDatePicker(context: ctx, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked == null) return;
    setState(() {
      if (isFrom) _from = picked;
      else _to = picked;
      // ensure order
      if (_from != null && _to != null && _from!.isAfter(_to!)) {
        final tmp = _from;
        _from = _to;
        _to = tmp;
      }
    });
  }

  void _reset() {
    setState(() {
      _from = null;
      _to = null;
      _status = 'All';
      _type = 'All';
    });
  }

  void _apply() {
    // return map: { from, to, status, type }
    Navigator.of(context).pop({
      'from': _from,
      'to': _to,
      'status': _status,
      'type': _type,
    });
  }

  Widget _statusButton(String label) {
    final active = _status == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF7931E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFFF7931E) : Colors.grey.shade300),
          ),
          child: Center(child: Text(label == 'All' ? 'Semua' : label, style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  Widget _typeOption(String label) {
    final active = _type == label;
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF7931E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? const Color(0xFFF7931E) : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // handle
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 12),

                Row(children: [
                  const Text('Filter Riwayat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ]),

                const SizedBox(height: 8),

                const Text('Jenis Perhitungan', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  _typeOption('All'),
                  _typeOption('Emas Fisik'),
                  _typeOption('Pivot Point'),
                ]),

                const SizedBox(height: 12),

                const Text('Rentang Waktu', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(context, true),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Align(alignment: Alignment.centerLeft, child: Text(_from == null ? 'Dari' : _formatDate(_from!))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(context, false),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Align(alignment: Alignment.centerLeft, child: Text(_to == null ? 'Sampai' : _formatDate(_to!))),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                Row(children: [
                  _statusButton('All'),
                  _statusButton('Profit'),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = 'Loss'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _status == 'Loss' ? const Color(0xFFF7931E) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _status == 'Loss' ? const Color(0xFFF7931E) : Colors.grey.shade300),
                        ),
                        child: Center(child: Text('Loss', style: TextStyle(color: _status == 'Loss' ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 18),

                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Atur Ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7931E), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}