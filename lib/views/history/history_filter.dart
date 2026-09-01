// lib/views/history/history_filter.dart
import 'package:flutter/material.dart';

class HistoryFilter extends StatefulWidget {
  const HistoryFilter({super.key});
  @override
  State<HistoryFilter> createState() => _HistoryFilterState();
}

class _HistoryFilterState extends State<HistoryFilter> {
  DateTime? from;
  DateTime? to;
  String status = 'All'; // All / Profit / Loss
  String type = 'All'; // All / Emas Fisik / Pivot Point

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => to = picked);
  }

  void _apply() {
    Navigator.of(context).pop({'from': from, 'to': to, 'status': status, 'type': type});
  }

  void _reset() {
    setState(() {
      from = null;
      to = null;
      status = 'All';
      type = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // for keyboard if any
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Filter Riwayat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // date range
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickFrom,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(from == null ? 'Dari' : '${from!.day.toString().padLeft(2, '0')}/${from!.month.toString().padLeft(2, '0')}/${from!.year}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTo,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(to == null ? 'Sampai' : '${to!.day.toString().padLeft(2, '0')}/${to!.month.toString().padLeft(2, '0')}/${to!.year}'),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // status buttons
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: status == 'All',
                    onSelected: (_) => setState(() => status = 'All'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Profit'),
                    selected: status == 'Profit',
                    onSelected: (_) => setState(() => status = 'Profit'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Loss'),
                    selected: status == 'Loss',
                    onSelected: (_) => setState(() => status = 'Loss'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // type dropdown
              Row(
                children: [
                  const Text('Tipe:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: type,
                    onChanged: (v) => setState(() => type = v ?? 'All'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('Semua')),
                      DropdownMenuItem(value: 'Emas Fisik', child: Text('Emas Fisik')),
                      DropdownMenuItem(value: 'Pivot Point', child: Text('Pivot Point')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Atur Ulang'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7931E)),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}