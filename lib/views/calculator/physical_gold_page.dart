import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'physical_gold_result_page.dart';

class ThousandsSeparatorInputFormatter
    extends TextInputFormatter {
  final bool allowDecimal;

  ThousandsSeparatorInputFormatter({
    this.allowDecimal = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Ubah titik desimal menjadi koma
    if (allowDecimal) {
      text = text.replaceAll('.', ',');
    } else {
      text = text.replaceAll('.', '');
      text = text.replaceAll(',', '');
    }

    // Hanya izinkan angka dan koma
    if (allowDecimal) {
      text = text.replaceAll(
        RegExp(r'[^0-9,]'),
        '',
      );

      // Hanya boleh satu koma
      final int firstComma = text.indexOf(',');

      if (firstComma != -1) {
        final String beforeComma =
            text.substring(0, firstComma);

        final String afterComma =
            text
                .substring(firstComma + 1)
                .replaceAll(',', '');

        text = '$beforeComma,$afterComma';
      }
    } else {
      text = text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
    }

    if (text.isEmpty) {
      return const TextEditingValue();
    }

    String integerPart = text;
    String decimalPart = '';

    if (allowDecimal && text.contains(',')) {
      final int commaIndex = text.indexOf(',');

      integerPart = text.substring(0, commaIndex);
      decimalPart = text.substring(commaIndex + 1);
    }

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    // Hapus nol di depan jika bukan angka desimal
    if (integerPart.length > 1) {
      integerPart =
          integerPart.replaceFirst(
        RegExp(r'^0+(?=\d)'),
        '',
      );
    }

    // Tambahkan titik ribuan
    final StringBuffer formattedInteger =
        StringBuffer();

    for (int i = 0;
        i < integerPart.length;
        i++) {
      if (i > 0 &&
          (integerPart.length - i) % 3 == 0) {
        formattedInteger.write('.');
      }

      formattedInteger.write(
        integerPart[i],
      );
    }

    String formatted =
        formattedInteger.toString();

    if (allowDecimal && text.contains(',')) {
      formatted += ',$decimalPart';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

class PhysicalGoldPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const PhysicalGoldPage({
    super.key,
    this.initialData,
  });

  @override
  State<PhysicalGoldPage> createState() => _PhysicalGoldPageState();
}

class _PhysicalGoldPageState extends State<PhysicalGoldPage> {
  // CONTROLLER INPUT
  final TextEditingController _modalController = TextEditingController();
  final TextEditingController _kursController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();

  // TRAY OUNCE (TOz)
  static const double _toz = 31.1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ISI ULANG DATA DARI HISTORY
  void _loadInitialData() {
    final data = widget.initialData;

    if (data == null) return;

    _modalController.text = _formatInitialNumber(data['modal']);
    _kursController.text = _formatInitialNumber(data['kurs']);
    _hargaBeliController.text = _formatInitialNumber(data['hargaBeli']);
    _hargaJualController.text = _formatInitialNumber(data['hargaJual']);
  }

  // FORMAT ANGKA UNTUK INPUT
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

    final double? number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.truncateToDouble()) {
      return number.toInt().toString();
    }

    return number.toString();
  }

  // SIMPAN HISTORY
  Future<void> _saveHistory({
    required double modal,
    required double kurs,
    required double hargaBeli,
    required double hargaJual,
    required double step1,
    required double step2,
    required double step3,
    required double step4,
    required double step5,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("history_data") ?? [];

    final item = {
      "type": "emas fisik",
      "date": DateTime.now().toString().substring(0, 16),
      "detail": {
        "modal": modal,
        "kurs": kurs,
        "hargaBeli": hargaBeli,
        "hargaJual": hargaJual,
        "step1": step1,
        "step2": step2,
        "step3": step3,
        "step4": step4,
        "step5": step5,
      },
      "result": step5 >= 0 ? "Profit" : "Loss",
    };

    data.add(jsonEncode(item));

    await prefs.setStringList(
      "history_data",
      data,
    );
  }

  // FORMAT ANGKA
  static double _truncateInteger(double value) {
    return value.truncateToDouble();
  }

  // POTONG MAKSIMAL 2 DESIMAL
  static double _truncateTo2(double value) {
    return (value * 100).truncateToDouble() / 100;
  }

  // FORMAT INTEGER DENGAN TITIK RIBUAN
  static String _formatInteger(double value) {
    final int number = value.truncate();
    final bool negative = number < 0;
    final String digits = number.abs().toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write('.');
      }

      result.write(digits[i]);
    }

    return negative ? '-${result.toString()}' : result.toString();
  }

  // FORMAT 2 ANGKA DESIMAL
  static String _formatTwoDecimals(double value) {
    final double truncated = _truncateTo2(value);
    final bool negative = truncated < 0;
    final double absoluteValue = truncated.abs();
    final int integerPart = absoluteValue.truncate();

    final int decimalPart =
        ((absoluteValue - integerPart) * 100).truncate();

    final String decimalText =
        decimalPart.toString().padLeft(2, '0');

    final String result =
        '${_formatInteger(integerPart.toDouble())},$decimalText';

    return negative ? '-$result' : result;
  }

  // PARSE INPUT
  double _parseNumber(String value) {
    String text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    text = text
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll(' ', '');

    // Format Indonesia:
    // 100.000.000 -> 100000000
    if (text.contains('.')) {
      text = text.replaceAll('.', '');
    }

    // Koma digunakan sebagai desimal
    if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }

    return double.tryParse(text) ?? 0;
  }

  // HITUNG
  Future<void> _calculate() async {
    final double modal = _parseNumber(
      _modalController.text,
    );

    final double kurs = _parseNumber(
      _kursController.text,
    );

    final double hargaBeli = _parseNumber(
      _hargaBeliController.text,
    );

    final double hargaJual = _parseNumber(
      _hargaJualController.text,
    );

    // VALIDASI INPUT
    if (modal <= 0 ||
        kurs <= 0 ||
        hargaBeli <= 0 ||
        hargaJual <= 0) {
      _showError(
        'Silakan isi Modal, Kurs, Harga Beli, dan Harga Jual.',
      );
      return;
    }

    // STEP 1
    // Harga Beli × Kurs ÷ TOz
    final double rawStep1 =
        (hargaBeli * kurs) / _toz;

    final double step1 =
        _truncateInteger(rawStep1);

    if (step1 <= 0) {
      _showError(
        'Hasil Harga Beli tidak valid.',
      );
      return;
    }

    // STEP 2
    // Harga Jual × Kurs ÷ TOz
    final double rawStep2 =
        (hargaJual * kurs) / _toz;

    final double step2 =
        _truncateInteger(rawStep2);

    // STEP 3
    // Step 2 − Step 1
    final double step3 =
        _truncateInteger(step2 - step1);

    // STEP 4
    // Modal ÷ Step 1
    final double step4 =
        _truncateTo2(modal / step1);

    // STEP 5
    // Step 3 × Step 4
    final double rawStep5 =
        step3 * step4;

    final double step5 =
        _truncateInteger(rawStep5);

    // SIMPAN HISTORY OTOMATIS
    await _saveHistory(
      modal: modal,
      kurs: kurs,
      hargaBeli: hargaBeli,
      hargaJual: hargaJual,
      step1: step1,
      step2: step2,
      step3: step3,
      step4: step4,
      step5: step5,
    );

    // BUKA HALAMAN HASIL
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PhysicalGoldResultPage(
            // DATA INPUT
            modal: modal,
            kurs: kurs,
            hargaBeli: hargaBeli,
            hargaJual: hargaJual,

            // HASIL
            step1: step1,
            step2: step2,
            step3: step3,
            step4: step4,
            step5: step5,
          );
        },
      ),
    );
  }

  // ERROR SNACKBAR
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // RESET INPUT
  void _reset() {
    setState(() {
      _modalController.clear();
      _kursController.clear();
      _hargaBeliController.clear();
      _hargaJualController.clear();
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Semua input berhasil direset.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // DISPOSE CONTROLLER
  @override
  void dispose() {
    _modalController.dispose();
    _kursController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.22),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFF7931E),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Kalkulator ',
                style: TextStyle(
                  color: Color(0xFF333333),
                ),
              ),
              TextSpan(
                text: 'Emas Fisik',
                style: TextStyle(
                  color: Color(0xFFF7931E),
                ),
              ),
            ],
          ),
        ),

        titleSpacing: 0,
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          12,
          18,
          12,
          30,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DESKRIPSI
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: Text(
                'Hitung selisih harga beli dan harga jual '
                'serta estimasi keuntungan atau kerugian '
                'berdasarkan modal dan kurs.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF222222),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // INPUT PERHITUNGAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6CBB8),
                  width: 1,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // JUDUL
                  Row(
                    children: [
                      const Icon(
                        Icons.input_outlined,
                        color: Color(0xFFF7931E),
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Input Perhitungan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // MODAL
                  _buildInputField(
                    controller: _modalController,
                    label: 'Modal (IDR)',
                    hint: 'Cnth : 100.000.000',
                    keyboardType: TextInputType.number,
                    allowDecimal: false,
                  ),

                  const SizedBox(height: 12),

                  // KURS
                  _buildInputField(
                    controller: _kursController,
                    label: 'Kurs (IDR)',
                    hint: 'Cnth : 16.000',
                    keyboardType: TextInputType.number,
                    allowDecimal: false,
                  ),

                  const SizedBox(height: 12),

                  // HARGA BELI
                  _buildInputField(
                    controller: _hargaBeliController,
                    label: 'Harga Beli',
                    hint: 'Cnth : 4.300',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    allowDecimal: true,
                  ),

                  const SizedBox(height: 12),

                  // HARGA JUAL
                  _buildInputField(
                    controller: _hargaJualController,
                    label: 'Harga Jual',
                    hint: 'Cnth: 4.302',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    allowDecimal: true,
                  ),

                  const SizedBox(height: 12),

                  // TOz TETAP
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFFF3C28D),
                      ),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Color(0xFFF7931E),
                          size: 18,
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            'TOz',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A4638),
                            ),
                          ),
                        ),

                        Text(
                          _formatTwoDecimals(_toz),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE47700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // HITUNG
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 19,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hitung',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

  // RESET
  Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    child: SizedBox(
      width: double.infinity,
      height: 34,
      child: OutlinedButton(
        onPressed: _reset,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF222222),
          side: const BorderSide(
            color: Color(0xFF666666),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: const Text(
          'Reset',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
  const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    // INPUT FIELD
    Widget _buildInputField({
      required TextEditingController controller,
      required String label,
      required String hint,
      required TextInputType keyboardType,
      required bool allowDecimal,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'monospace',
              color: Color(0xFF5A4638),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F4F3),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF777777),
                  width: 1.5,
                ),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(
                  allowDecimal: allowDecimal,
                ),
              ],
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737987).withValues(alpha: 0.55),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }