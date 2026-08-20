import 'package:flutter/material.dart';

class PhysicalGoldResultPage extends StatelessWidget {
  // DATA INPUTAN
  final double modal;
  final double kurs;
  final double hargaBeli;
  final double hargaJual;

  // HASIL PERHITUNGAN
  final double step1;
  final double step2;
  final double step3;
  final double step4;
  final double step5;

  // CALLBACK UNTUK MENYIMPAN PERHITUNGAN KE RIWAYAT
  final VoidCallback? onSave;

  // KONSTANTA
  static const double _toz = 31.1;

  const PhysicalGoldResultPage({
    super.key,
    required this.modal,
    required this.kurs,
    required this.hargaBeli,
    required this.hargaJual,
    required this.step1,
    required this.step2,
    required this.step3,
    required this.step4,
    required this.step5,
    this.onSave,
  });

  // FORMAT TOz
  static String _formatToz(double value) {
      return value.toString().replaceAll('.', ',');
  }

  // FORMAT ANGKA BULAT
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

  // FORMAT ANGKA DENGAN 2 DESIMAL
  static String _formatTwoDecimals(double value) {
    final double truncated =
        (value * 100).truncateToDouble() / 100;

    final bool negative = truncated < 0;

    final double absoluteValue =
        truncated.abs();

    final int integerPart =
        absoluteValue.truncate();

    int decimalPart =
        ((absoluteValue - integerPart) * 100)
            .truncate();

    final String decimalText =
        decimalPart.toString().padLeft(2, '0');

    final String result =
        '${_formatInteger(integerPart.toDouble())},$decimalText';

    return negative ? '-$result' : result;
  }

  // BUILD WIDGET
  @override
  Widget build(BuildContext context) {
    final bool isProfit = step5 >= 0;

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
                text: 'Hasil Perhitungan ',
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
                'Hasil perhitungan berdasarkan modal, '
                'kurs, harga beli, dan harga jual '
                'emas fisik.',

                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF222222),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // CARD UTAMA HASIL PERHITUNGAN
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                18,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF7),

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
                  // HEADER CARD
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [
                      Container(
                        width: 34,
                        height: 34,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFEBD3),

                          borderRadius:
                              BorderRadius.circular(8),
                        ),

                        child: const Icon(
                          Icons.analytics_outlined,
                          color:
                              Color(0xFFF7931E),
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Hasil Perhitungan',

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

                  const SizedBox(height: 16),

                  // LABEL HASIL PERHITUNGAN
                  const Center(
                    child: Text(
                      'ESTIMASI KEUNTUNGAN / KERUGIAN',

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                        color:
                            Color(0xFF777777),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // NILAI HASIL PERHITUNGAN
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,

                      child: Text(
                        'Rp ${_formatInteger(step5)}',

                        style: TextStyle(
                          fontSize: 31,
                          fontWeight:
                              FontWeight.bold,
                          color: isProfit
                              ? const Color(
                                  0xFFF7931E,
                                )
                              : const Color(
                                  0xFFD32F2F,
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // STATUS PROFIT / LOSS
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: isProfit
                            ? const Color(
                                0xFFFFF1DD,
                              )
                            : const Color(
                                0xFFFFEAEA,
                              ),

                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          Icon(
                            isProfit
                                ? Icons
                                    .trending_up
                                : Icons
                                    .trending_down,

                            size: 14,

                            color: isProfit
                                ? const Color(
                                    0xFFE47700,
                                  )
                                : const Color(
                                    0xFFD32F2F,
                                  ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            isProfit
                                ? 'Profit'
                                : 'Loss',

                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,

                              color: isProfit
                                  ? const Color(
                                      0xFFE47700,
                                    )
                                  : const Color(
                                      0xFFD32F2F,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BATAS
                  Container(
                    height: 1,
                    color:
                        const Color(0xFFE6D4C4),
                  ),

                  const SizedBox(height: 12),

                  // JUDUL RINCIAN PERHITUNGAN
                  const Text(
                    'Rincian Perhitungan',

                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF5A4638),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 1,
                    color:
                        const Color(0xFFE6D4C4),
                  ),

                  const SizedBox(height: 12),

                  // INPUTAN
                  _buildInputRow(
                    label: 'Modal',
                    value:
                        'Rp ${_formatInteger(modal)}',
                  ),

                  _buildInputRow(
                    label: 'Kurs',
                    value:
                        'Rp ${_formatInteger(kurs)}',
                  ),

                  _buildInputRow(
                    label: 'Harga Beli',
                    value:
                        _formatInteger(hargaBeli),
                  ),

                  _buildInputRow(
                    label: 'Harga Jual',
                    value:
                        _formatInteger(hargaJual),
                  ),

                  _buildInputRow(
                    label: 'TOz',
                    value: _formatToz(_toz),
                  ),

                  const SizedBox(height: 8),

                  // PEMBATAS
                  Container(
                    height: 1,
                    color:
                        const Color(0xFFE6D4C4),
                  ),

                  const SizedBox(height: 12),

                  // STEP1
                  _buildStepRow(
                    number: '1',
                    label:
                        'Harga Beli per TOz',
                    formula:
                        'Harga Beli × Kurs ÷ 31,1',
                    value:
                        'Rp ${_formatInteger(step1)}',
                  ),

                  // STEP2
                  _buildStepRow(
                    number: '2',
                    label:
                        'Harga Jual per TOz',
                    formula:
                        'Harga Jual × Kurs ÷ 31,1',
                    value:
                        'Rp ${_formatInteger(step2)}',
                  ),

                  // STEP3
                  _buildStepRow(
                    number: '3',
                    label: 'Selisih Harga',
                    formula:
                        'Step 2 − Step 1',
                    value:
                        'Rp ${_formatInteger(step3)}',
                  ),

                  // STEP4
                  _buildStepRow(
                    number: '4',
                    label: 'Jumlah Emas',
                    formula:
                        'Modal ÷ Step 1',
                    value:
                        '${_formatTwoDecimals(step4)} TOz',
                  ),

                  // STEP5
                  _buildStepRow(
                    number: '5',
                    label: 'Profit / Loss',
                    formula:
                        'Step 3 × Step 4',
                    value:
                        'Rp ${_formatInteger(step5)}',
                    isFinal: true,
                  ),

                  const SizedBox(height: 16),

                  // SIMPAN PERHITUNGAN
                  SizedBox(
                    width: double.infinity,
                    height: 42,

                    child: OutlinedButton(
                      onPressed: () {
                        if (onSave != null) {
                          onSave!();
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Perhitungan siap disimpan ke riwayat.',
                              ),
                              behavior:
                                  SnackBarBehavior
                                      .floating,
                            ),
                          );
                        }
                      },

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF9A5700),

                        side:
                            const BorderSide(
                          color:
                              Color(0xFFC47A21),
                          width: 1.3,
                        ),

                        backgroundColor:
                            Colors.white,

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
                            Icons
                                .save_outlined,
                            size: 18,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'Simpan Perhitungan',

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // HITUNG LAGI
                  SizedBox(
                    width: double.infinity,
                    height: 42,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

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
                            Icons
                                .calculate_outlined,
                            size: 18,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'Hitung Lagi',

                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INPUT ROW
  Widget _buildInputRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              label,

              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,

              textAlign: TextAlign.right,

              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight:
                    FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP ROW
  Widget _buildStepRow({
    required String number,
    required String label,
    required String formula,
    required String value,
    bool isFinal = false,
  }) {
    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 10),

      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: isFinal
            ? const Color(0xFFFFF1DD)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(8),

        border: Border.all(
          color: isFinal
              ? const Color(0xFFF7931E)
              : const Color(0xFFE3D7CD),

          width: isFinal ? 1.2 : 1,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // NOMOR
          Container(
            width: 24,
            height: 24,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFF7931E),

              borderRadius:
                  BorderRadius.circular(6),
            ),

            child: Center(
              child: Text(
                number,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          // DETAIL
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                    color: isFinal
                        ? const Color(
                            0xFFE47700,
                          )
                        : const Color(
                            0xFF333333,
                          ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  formula,

                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color:
                        Color(0xFF888888),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment:
                      Alignment.centerRight,

                  child: Text(
                    value,

                    textAlign:
                        TextAlign.right,

                    style: TextStyle(
                      fontSize: 15,
                      fontFamily:
                          'monospace',
                      fontWeight:
                          FontWeight.bold,

                      color: isFinal
                          ? const Color(
                              0xFFE47700,
                            )
                          : const Color(
                              0xFF333333,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}