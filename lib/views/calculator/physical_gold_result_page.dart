import 'package:flutter/material.dart';

class PhysicalGoldResultPage extends StatefulWidget {
  final double modal;
  final double kurs;
  final double hargaBeli;
  final double hargaJual;
  final double step1;
  final double step2;
  final double step3;
  final double step4;
  final double step5;
  final VoidCallback? onSave;

  static const double toz = 31.1;

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

  @override
  State<PhysicalGoldResultPage> createState() =>
      _PhysicalGoldResultPageState();
}

class _PhysicalGoldResultPageState
    extends State<PhysicalGoldResultPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onSave != null) {
        widget.onSave!();
      }
    });
  }

  static String _formatToz(double value) {
    return value.toString().replaceAll('.', ',');
  }

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

  static String _formatTwoDecimals(double value) {
    final double truncated =
        (value * 100).truncateToDouble() / 100;

    final bool negative = truncated < 0;
    final double absValue = truncated.abs();

    final int integerPart = absValue.truncate();

    final int decimalPart =
        ((absValue - integerPart) * 100).truncate();

    final String decimalText =
        decimalPart.toString().padLeft(2, '0');

    final String result =
        '${_formatInteger(integerPart.toDouble())},$decimalText';

    return negative ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isProfit = widget.step5 >= 0;

    final Color statusColor = isProfit
        ? const Color(0xFF2E9B4B)
        : const Color(0xFFD32F2F);

    final Color statusBgColor = isProfit
        ? const Color(0xFFEAF7EE)
        : const Color(0xFFFFEAEA);

    return Scaffold(
      backgroundColor: Colors.white,
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
            const SizedBox(
              height: 18,
            ),
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6CBB8),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBD3),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Color(0xFFF7931E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Hasil Perhitungan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // HASIL UTAMA + WATERMARK
                  SizedBox(
                    width: double.infinity,
                    height: 105,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        
                        Positioned(
                          left: 40,
                          right: 20,
                          top: -50,
                          child: IgnorePointer(
                            child: Center(
                              child: Opacity(
                                opacity: 0.50,
                                child: Image.asset(
                                  'assets/images/ewf.jpg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: 20,
                          right: 20,
                          top: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'ESTIMASI KEUNTUNGAN / KERUGIAN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1,
                                  color: Color(0xFF777777),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatInteger(widget.step5)}',
                                style: const TextStyle(
                                  fontSize: 31,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE47700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isProfit
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isProfit ? 'Profit' : 'Loss',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 1,
                    color: const Color(0xFFE6D4C4),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    'Rincian Perhitungan',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A4638),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInputRow(
                    label: 'Modal',
                    value:
                        'Rp ${_formatInteger(widget.modal)}',
                  ),

                  _buildInputRow(
                    label: 'Kurs',
                    value:
                        'Rp ${_formatInteger(widget.kurs)}',
                  ),

                  _buildInputRow(
                    label: 'Harga Beli',
                    value:
                        _formatInteger(widget.hargaBeli),
                  ),

                  _buildInputRow(
                    label: 'Harga Jual',
                    value:
                        _formatInteger(widget.hargaJual),
                  ),

                  _buildInputRow(
                    label: 'TOz',
                    value: _formatToz(
                      PhysicalGoldResultPage.toz,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Container(
                    height: 1,
                    color: const Color(0xFFE6D4C4),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildStepRow(
                    number: '1',
                    label: 'Harga Beli per TOz',
                    formula:
                        'Harga Beli × Kurs ÷ 31,1',
                    value:
                        'Rp ${_formatInteger(widget.step1)}',
                  ),

                  _buildStepRow(
                    number: '2',
                    label: 'Harga Jual per TOz',
                    formula:
                        'Harga Jual × Kurs ÷ 31,1',
                    value:
                        'Rp ${_formatInteger(widget.step2)}',
                  ),

                  _buildStepRow(
                    number: '3',
                    label: 'Selisih Harga',
                    formula: 'Step 2 − Step 1',
                    value:
                        'Rp ${_formatInteger(widget.step3)}',
                  ),

                  _buildStepRow(
                    number: '4',
                    label: 'Jumlah Emas',
                    formula: 'Modal ÷ Step 1',
                    value:
                        '${_formatTwoDecimals(widget.step4)} TOz',
                  ),

                  _buildStepRow(
                    number: '5',
                    label: 'Profit / Loss',
                    formula: 'Step 3 × Step 4',
                    value:
                        'Rp ${_formatInteger(widget.step5)}',
                    isFinal: true,
                    isProfit: isProfit,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

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
                        foregroundColor: Colors.white,
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
                            size: 18,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Hitung Ulang',
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

  Widget _buildInputRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String label,
    required String formula,
    required String value,
    bool isFinal = false,
    bool isProfit = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isFinal
            ? const Color(0xFFFFF1DD)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFinal
              ? const Color(0xFFF7931E)
              : const Color(0xFFE3D7CD),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF7931E),
              borderRadius:
                  BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFinal
                        ? const Color(0xFFE47700)
                        : const Color(0xFF333333),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Align(
                  alignment:
                      Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: isFinal
                          ? const Color(0xFFE47700)
                          : const Color(0xFF333333),
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