import 'package:flutter/material.dart';
import '../../services/market_service.dart';
import 'pivot_result_page.dart';

class PivotPointPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const PivotPointPage({
    super.key,
    this.initialData,
  });

  @override
  State<PivotPointPage> createState() => _PivotPointPageState();
}

class _PivotPointPageState extends State<PivotPointPage> {
  final TextEditingController _openController = TextEditingController();
  final TextEditingController _highController = TextEditingController();
  final TextEditingController _lowController = TextEditingController();
  final TextEditingController _closeController = TextEditingController();

  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF555555);
  static const Color fieldColor = Color(0xFFF7F5F3);

  bool _isLoading = false;
  String? _errorMessage;
  String? _dataDate;

  bool get _isRecalculate => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    if (_isRecalculate) {
      _loadInitialData();
    } else {
      _loadGoldData();
    }
  }

  void _loadInitialData() {
    final d = widget.initialData!;

    _openController.text = _formatInitialNumber(d['open']);
    _highController.text = _formatInitialNumber(d['high']);
    _lowController.text = _formatInitialNumber(d['low']);
    _closeController.text = _formatInitialNumber(d['close']);

    _dataDate = d['dataDate']?.toString() ?? d['date']?.toString();

    setState(() {});
  }

  String _formatInitialNumber(dynamic value) {
    if (value == null) return '';

    if (value is int) {
      return value.toString();
    }

    if (value is double) {
      if (value == value.truncateToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }

    final number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.truncateToDouble()) {
      return number.toInt().toString();
    }

    return number.toString();
  }

  @override
  void dispose() {
    _openController.dispose();
    _highController.dispose();
    _lowController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  Future<void> _loadGoldData({String? date}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        'Mengambil data gold${date != null ? ' untuk $date' : ''}...',
      );

      final Map<String, dynamic> data =
          await MarketService.getLatestGoldData(date: date);

      debugPrint('Data gold berhasil diterima: $data');

      final String? open = data['open']?.toString();
      final String? high = data['high']?.toString();
      final String? low = data['low']?.toString();
      final String? close = data['close']?.toString();
      final String? tanggal = data['tanggal']?.toString();

      if (open == null ||
          high == null ||
          low == null ||
          close == null ||
          open.isEmpty ||
          high.isEmpty ||
          low.isEmpty ||
          close.isEmpty) {
        throw Exception(
          'Data Open, High, Low, atau Close tidak tersedia.',
        );
      }

      if (!mounted) return;

      setState(() {
        _openController.text = open;
        _highController.text = high;
        _lowController.text = low;
        _closeController.text = close;
        _dataDate = tanggal;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Gagal mengambil data gold: $error');

      setState(() {
        _isLoading = false;

        if (date != null) {
          _errorMessage =
              'Data emas untuk tanggal ${_formatDate(date)} tidak tersedia.';
        } else {
          _errorMessage =
              'Tidak dapat mengambil data emas.\n'
              'Periksa koneksi internet atau API Newsmaker.';
        }
      });
    }
  }

  Future<void> _selectDate() async {
    if (_isLoading || _isRecalculate) return;

    DateTime initialDate;

    if (_dataDate != null && _dataDate!.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dataDate!);
      } catch (_) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih tanggal data emas',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final String selectedDate =
        '${pickedDate.year.toString().padLeft(4, '0')}-'
        '${pickedDate.month.toString().padLeft(2, '0')}-'
        '${pickedDate.day.toString().padLeft(2, '0')}';

    await _loadGoldData(date: selectedDate);

    if (!mounted) return;

    if (_errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data ${_formatDate(selectedDate)} berhasil dimuat.',
          ),
          backgroundColor: orange,
        ),
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    final parts = date.split('-');

    if (parts.length != 3) return date;

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  double? _parseNumber(String value) {
    if (value.trim().isEmpty) return null;

    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  bool get _hasGoldData {
    return _openController.text.isNotEmpty &&
        _highController.text.isNotEmpty &&
        _lowController.text.isNotEmpty &&
        _closeController.text.isNotEmpty;
  }

  void _calculatePivot() {
    final double? open = _parseNumber(_openController.text);
    final double? high = _parseNumber(_highController.text);
    final double? low = _parseNumber(_lowController.text);
    final double? close = _parseNumber(_closeController.text);

    if (!_hasGoldData ||
        open == null ||
        high == null ||
        low == null ||
        close == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data emas belum tersedia. Silakan pilih tanggal atau refresh data.',
          ),
          backgroundColor: orange,
        ),
      );
      return;
    }

    if (high <= low) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harga High harus lebih besar dari Harga Low.',
          ),
          backgroundColor: orange,
        ),
      );
      return;
    }

    final bool hasDecimalInput =
        _openController.text.contains('.') ||
        _openController.text.contains(',') ||
        _highController.text.contains('.') ||
        _highController.text.contains(',') ||
        _lowController.text.contains('.') ||
        _lowController.text.contains(',') ||
        _closeController.text.contains('.') ||
        _closeController.text.contains(',');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PivotResultPage(
          open: open,
          high: high,
          low: low,
          close: close,
          hasDecimalInput: hasDecimalInput,
          dataDate: _dataDate,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    if (_isRecalculate) return;

    await _loadGoldData();

    if (!mounted) return;

    if (_errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data emas berhasil diperbarui.'),
          backgroundColor: orange,
        ),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: readOnly
                  ? const Color(0xFFF1EFED)
                  : fieldColor,
              border: Border(
                bottom: BorderSide(
                  color: readOnly
                      ? orange
                      : Colors.grey.shade600,
                  width: 1.2,
                ),
              ),
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                color: readOnly ? Colors.black87 : darkText,
                fontWeight:
                    readOnly ? FontWeight.w600 : FontWeight.normal,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.grey,
                ),
                suffixIcon: readOnly
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.lock_outline,
                          color: orange,
                          size: 18,
                        ),
                      )
                    : _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: orange,
                              ),
                            ),
                          )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.20),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: orange,
            size: 21,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            children: [
              TextSpan(text: 'Kalkulator '),
              TextSpan(
                text: 'Pivot',
                style: TextStyle(color: orange),
              ),
            ],
          ),
        ),
        actions: [
          if (!_isRecalculate)
            IconButton(
              tooltip: 'Refresh Data',
              onPressed: _isLoading ? null : _refreshData,
              icon: const Icon(
                Icons.refresh,
                color: orange,
                size: 23,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    'Hitung titik keseimbangan atau level harga acuan berdasarkan pergerakan harga pada periode sebelumnya.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: const Color(0xFFF3D2B0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_download_outlined,
                            color: orange,
                            size: 25,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data LGD Daily',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isRecalculate
                                        ? 'Data dari riwayat'
                                        : _isLoading
                                            ? 'Mengambil data terbaru...'
                                            : _errorMessage ??
                                                'Tanggal: ${_formatDate(_dataDate)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _errorMessage != null
                                          ? Colors.red
                                          : greyText,
                                    ),
                                  ),
                                  if (!_isRecalculate &&
                                      !_isLoading &&
                                      _errorMessage == null) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _selectDate,
                                      child: const Icon(
                                        Icons.calendar_month,
                                        color: orange,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCFA),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFE6D7CA),
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: orange,
                          width: 3,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 9,
                      right: 0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.input,
                              color: orange,
                              size: 19,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Data Perhitungan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          label: 'Harga Open',
                          hint: 'Menunggu data realtime...',
                          controller: _openController,
                          readOnly: true,
                        ),
                        _buildInputField(
                          label: 'Harga High',
                          hint: 'Menunggu data...',
                          controller: _highController,
                        ),
                        _buildInputField(
                          label: 'Harga Low',
                          hint: 'Menunggu data...',
                          controller: _lowController,
                        ),
                        _buildInputField(
                          label: 'Harga Close',
                          hint: 'Menunggu data...',
                          controller: _closeController,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading || !_hasGoldData
                              ? null
                              : _calculatePivot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        disabledBackgroundColor:
                            Colors.grey.shade300,
                        disabledForegroundColor:
                            Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate, size: 19),
                          SizedBox(width: 8),
                          Text(
                            'Hitung',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}