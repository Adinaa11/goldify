import 'package:flutter/material.dart';
import 'physical_gold_result_page.dart';

class PhysicalGoldPage extends StatefulWidget {
  const PhysicalGoldPage({super.key});

  @override
  State<PhysicalGoldPage> createState() => _PhysicalGoldPageState();
}

class _PhysicalGoldPageState extends State<PhysicalGoldPage> {
  // CONTROLLER INPUT
  final TextEditingController _modalController =
      TextEditingController();

  final TextEditingController _kursController =
      TextEditingController();

  final TextEditingController _hargaBeliController =
      TextEditingController();

  final TextEditingController _hargaJualController =
      TextEditingController();

  // TRAY OUNCE (TOz)
  static const double _toz = 31.1;

  // FORMAT ANGKA
  static double _truncateInteger(double value) {
    return value.truncateToDouble();
  }

  /// Memotong angka menjadi maksimal 2 angka desimal.
  /// Tidak melakukan pembulatan.
  static double _truncateTo2(double value) {
    return (value * 100).truncateToDouble() / 100;
  }

  /// Format angka integer menggunakan titik sebagai
  /// pemisah ribuan.
  ///
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

    return negative
        ? '-${result.toString()}'
        : result.toString();
  }

  /// Format angka dengan 2 angka di belakang koma.
  ///
  /// Titik = ribuan
  /// Koma = desimal
  static String _formatTwoDecimals(double value) {
    final double truncated = _truncateTo2(value);

    final bool negative = truncated < 0;

    final double absoluteValue = truncated.abs();

    final int integerPart = absoluteValue.truncate();

    int decimalPart =
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

    // Hapus Rp dan spasi.
    text = text
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll(' ', '');

    // Format Indonesia:
    // 4.300,50 -> 4300.50
    if (text.contains(',') && text.contains('.')) {
      text = text.replaceAll('.', '');
      text = text.replaceAll(',', '.');
    }

    // Jika hanya menggunakan koma,
    // dianggap sebagai desimal.
    else if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }

    return double.tryParse(text) ?? 0;
  }

  // HITUNG
  void _calculate() {
    final double modal =
        _parseNumber(_modalController.text);

    final double kurs =
        _parseNumber(_kursController.text);

    final double hargaBeli =
        _parseNumber(_hargaBeliController.text);

    final double hargaJual =
        _parseNumber(_hargaJualController.text);

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

    // STEP 1 Harga Beli × Kurs ÷ TOz
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

    // STEP 2 Harga Jual × Kurs ÷ TOz
    final double rawStep2 =
        (hargaJual * kurs) / _toz;

    final double step2 =
        _truncateInteger(rawStep2);

    // STEP 3 Step 2 − Step 1
    final double step3 =
        _truncateInteger(step2 - step1);

    // STEP 4 Modal ÷ Step 1
    final double step4 =
        _truncateTo2(modal / step1);

    // STEP 5 Step 3 × Step 4
    final double rawStep5 =
        step3 * step4;

    final double step5 =
        _truncateInteger(rawStep5);

    // BUKA HALAMAN HASIL PERHITUNGAN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PhysicalGoldResultPage(
            // DATA INPUTAN
            modal: modal,
            kurs: kurs,
            hargaBeli: hargaBeli,
            hargaJual: hargaJual,

            // HASIL PERHITUNGAN
            step1: step1,
            step2: step2,
            step3: step3,
            step4: step4,
            step5: step5,

            // CALLBACK SIMPAN
            onSave: () {
              _saveToHistory(
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
            },
          );
        },
      ),
    );
  }

  // SIMPAN KE RIWAYAT
  void _saveToHistory({
    required double modal,
    required double kurs,
    required double hargaBeli,
    required double hargaJual,
    required double step1,
    required double step2,
    required double step3,
    required double step4,
    required double step5,
  }) {
    /*
      NANTI BAGIAN INI DIHUBUNGKAN DENGAN DATABASE / STORAGE
      RIWAYAT.

      Data yang sudah tersedia:

      - tanggal & waktu saat disimpan
      - modal
      - kurs
      - harga beli
      - harga jual
      - TOz
      - step 1
      - step 2
      - step 3
      - step 4
      - step 5
      - profit / loss

      Untuk sementara tampilkan konfirmasi.
    */

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Perhitungan berhasil disimpan ke riwayat.',
        ),
        behavior: SnackBarBehavior.floating,
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

  // BUILD WIDGET
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor:
            Colors.black.withValues(alpha: 0.22),

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
          crossAxisAlignment:
              CrossAxisAlignment.start,

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

                borderRadius:
                    BorderRadius.circular(10),

                border: Border.all(
                  color: const Color(0xFFE6CBB8),
                  width: 1,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

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
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // MODAL
                  _buildInputField(
                    controller:
                        _modalController,

                    label:
                        'Modal (IDR)',

                    hint:
                        'Contoh: 100000000',

                    keyboardType:
                        TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  // KURS
                  _buildInputField(
                    controller:
                        _kursController,

                    label:
                        'Kurs (IDR)',

                    hint:
                        'Contoh: 16000',

                    keyboardType:
                        TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  // HARGA BELI
                  _buildInputField(
                    controller:
                        _hargaBeliController,

                    label:
                        'Harga Beli',

                    hint:
                        'Contoh: 4300',

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // HARGA JUAL
                  _buildInputField(
                    controller:
                        _hargaJualController,

                    label:
                        'Harga Jual',

                    hint:
                        'Contoh: 4302',

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TOz TETAP
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),

                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFFF4E5),

                      borderRadius:
                          BorderRadius.circular(7),

                      border: Border.all(
                        color:
                            const Color(0xFFF3C28D),
                      ),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color:
                              Color(0xFFF7931E),
                          size: 18,
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            'TOz',

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(0xFF5A4638),
                            ),
                          ),
                        ),

                        Text(
                          _formatTwoDecimals(_toz),

                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFFE47700),
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
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 44,

                child: ElevatedButton(
                  onPressed: _calculate,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF8C00),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(7),
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 19,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Hitung',

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
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
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 34,

                child: OutlinedButton(
                  onPressed: _reset,

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF222222),

                    side:
                        const BorderSide(
                      color:
                          Color(0xFF666666),
                      width: 1,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(7),
                    ),
                  ),

                  child: const Text(
                    'Reset',

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // KETERANGAN
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),

              child: Text(
                'Hasil perhitungan akan ditampilkan '
                'pada halaman berikutnya.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                ),
              ),
            ),
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
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            fontSize: 12,
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

            keyboardType:
                keyboardType,

            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: Color(0xFF555D6D),
            ),

            decoration:
                InputDecoration(
              hintText: hint,

              hintStyle:
                  const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Color(0xFF737987),
              ),

              border:
                  InputBorder.none,

              contentPadding:
                  const EdgeInsets.symmetric(
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