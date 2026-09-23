import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/physical_gold_model.dart';
import '../../repositories/physical_gold_repository.dart';
import '../../viewmodels/physical_gold_viewmodel.dart';

import 'physical_gold_result_page.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {

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

    if (allowDecimal) {
      text = text.replaceAll('.', ',');
    } else {
      text = text.replaceAll('.', '');
      text = text.replaceAll(',', '');
    }

    if (allowDecimal) {

      text = text.replaceAll(
        RegExp(r'[^0-9,]'),
        '',
      );

      final comma = text.indexOf(',');

      if (comma != -1) {

        final before =
            text.substring(0, comma);

        final after =
            text.substring(comma + 1)
            .replaceAll(',', '');

        text = '$before,$after';
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

      final index = text.indexOf(',');
      integerPart = text.substring(0,index);

      decimalPart =
          text.substring(index + 1);
    }

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    if (integerPart.length > 1) {

      integerPart =
          integerPart.replaceFirst(
            RegExp(r'^0+(?=\d)'),
            '',
          );
    }

    final buffer = StringBuffer();

    for(
      int i = 0;
      i < integerPart.length;
      i++
    ) {

      if(
        i > 0 &&
        (integerPart.length - i) % 3 == 0
      ) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    String formatted =
        buffer.toString();

    if(allowDecimal && text.contains(',')) {
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
  final Map<String,dynamic>? initialData;

  const PhysicalGoldPage({
    super.key,
    this.initialData,
  });

  @override
  State<PhysicalGoldPage> createState()
      => _PhysicalGoldPageState();
}

class _PhysicalGoldPageState
    extends State<PhysicalGoldPage> {

  late PhysicalGoldViewModel viewModel;

  final TextEditingController _modalController =
      TextEditingController();
  final TextEditingController _kursController =
      TextEditingController();
  final TextEditingController _hargaBeliController =
      TextEditingController();
  final TextEditingController _hargaJualController =
      TextEditingController();

  static const double _toz = 31.1;
  
  @override
  void initState() {
    super.initState();

    viewModel =
        PhysicalGoldViewModel(
          PhysicalGoldRepository(),
        );

    viewModel.addListener(() {
      if(!mounted) return;
      setState((){});
    });
    _loadInitialData();
  }

  void _loadInitialData() {
    final data =
        widget.initialData;

    if(data == null) return;

    _modalController.text =
        _formatInitialNumber(
          data['modal'],
        );

    _kursController.text =
        _formatInitialNumber(
          data['kurs'],
        );

    _hargaBeliController.text =
        _formatInitialNumber(
          data['hargaBeli']
          ??
          data['harga_beli'],
        );

    _hargaJualController.text =
        _formatInitialNumber(
          data['hargaJual']
          ??
          data['harga_jual'],
        );
  }

  String _formatInitialNumber(dynamic value) {
    if(value == null) {
      return '';
    }

    if(value is num) {
      if(value == value.truncateToDouble()) {
        return value.toInt().toString();

      }
      return value.toString();
    }

    final number =
        double.tryParse(
          value.toString(),
        );

    if(number == null) {
      return value.toString();
    }

    if(number == number.truncateToDouble()) {
      return number.toInt().toString();

    }
    return number.toString();
  }

  @override
  void dispose() {

    _modalController.dispose();
    _kursController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();

    viewModel.dispose();

    super.dispose();
  }

  Future<void> _calculate() async {

    final PhysicalGoldModel? result =
        await viewModel.calculate(
          modalText:
          _modalController.text,
          kursText:
          _kursController.text,
          hargaBeliText:
          _hargaBeliController.text,
          hargaJualText:
          _hargaJualController.text,
        );

    if(!mounted) return;

    if(result == null) {

      ScaffoldMessenger.of(context)
      .showSnackBar(

        SnackBar(

          content:
          Text(
            viewModel.errorMessage
            ??
            'Data tidak valid.',
          ),

          backgroundColor:
          Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)

        => PhysicalGoldResultPage(
          modal:
          result.modal,
          kurs:
          result.kurs,
          hargaBeli:
          result.hargaBeli,
          hargaJual:
          result.hargaJual,

          step1:
          result.step1,
          step2:
          result.step2,
          step3:
          result.step3,
          step4:
          result.step4,
          step5:
          result.step5,
        ),
      ),
    );
  }

  void _reset(){
    setState((){
      _modalController.clear();
      _kursController.clear();
      _hargaBeliController.clear();
      _hargaJualController.clear();
    });

    FocusScope.of(context)
        .unfocus();

    ScaffoldMessenger.of(context)
    .showSnackBar(

      const SnackBar(
        content:
        Text(
          'Semua input berhasil direset.',
        ),

        behavior:
        SnackBarBehavior.floating,
        duration:
        Duration(seconds:1),
      ),
    );
  }

  static double _truncateTo2(
    double value,
  ){
    return
    (value * 100)
        .truncateToDouble() / 100;
  }

  static String _formatInteger(
    double value,
  ){

    final int number =
        value.truncate();

    final String digits =
        number.abs().toString();

    final buffer =
        StringBuffer();

    for(
      int i = 0;
      i < digits.length;
      i++
    ){

      if(
        i > 0 &&
        (digits.length - i) % 3 == 0
      ){
        buffer.write('.');
      }
      buffer.write(
        digits[i],
      );
    }
    return number < 0
        ? '-${buffer.toString()}'
        : buffer.toString();
  }

  static String _formatTwoDecimals(
    double value,
  ){

    final double truncated =
        _truncateTo2(value);

    final int integerPart =
        truncated.truncate();

    final int decimalPart =
        ((truncated - integerPart)
        .abs()
        *
        100)
        .truncate();

    return
    '${_formatInteger(
      integerPart.toDouble(),
    )},${decimalPart.toString().padLeft(2,'0')}';
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required bool allowDecimal,

  }){

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children:[
        Text(
          label,
          style:

          const TextStyle(
            fontSize:15,
            fontFamily:'monospace',
            color:
            Color(0xFF5A4638),
          ),
        ),

        const SizedBox(
          height:4,
        ),

        Container(
          height:38,
          decoration:

          const BoxDecoration(
            color:
            Color(0xFFF6F4F3),

            border:

            Border(
              bottom:

              BorderSide(
                color:
                Color(0xFF777777),

                width: 1.5,
              ),
            ),
          ),

          child:

          TextField(
            controller:
            controller,

            keyboardType:
            keyboardType,

            inputFormatters:[

              ThousandsSeparatorInputFormatter(
                allowDecimal:
                allowDecimal,
              ),
            ],

            style:
            const TextStyle(

              fontSize: 14,
              fontFamily:
              'monospace',
              fontWeight:
              FontWeight.w600,
              color:
              Color(0xFF222222),
            ),

            decoration:

            InputDecoration(
              hintText:
              hint,

              hintStyle:

              TextStyle(

                fontSize: 14,
                fontFamily:
                'monospace',
                fontWeight:
                FontWeight.w400,

                color:
                const Color(0xFF737987)
                .withValues(alpha:0.55),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.white,

      appBar:

      AppBar(
        backgroundColor:
        Colors.white,
        surfaceTintColor:
        Colors.white,
        elevation: 4,

        shadowColor:
        Colors.black.withValues(
          alpha:0.22,
        ),

        leading:

        IconButton(
          icon:

          const Icon(
            Icons.arrow_back_ios_new,
            color:
            Color(0xFFF7931E),
            size: 20,
          ),

          onPressed:(){
            Navigator.pop(context);
          },
        ),

        title:

        RichText(
          text:

          const TextSpan(
            style:

            TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),

            children:[

              TextSpan(
                text:
                'Kalkulator ',
                style:

                TextStyle(
                  color:
                  Color(0xFF333333),
                ),
              ),

              TextSpan(
                text:
                'Emas Fisik',

                style:

                TextStyle(
                  color:
                  Color(0xFFF7931E),
                ),
              ),
            ],
          ),
        ),

        titleSpacing: 0,
      ),

      body:

      SingleChildScrollView(
        padding:

        const EdgeInsets.fromLTRB(
          12,
          18,
          12,
          30,
        ),

        child:

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children:[
            const Padding(
              padding:

              EdgeInsets.symmetric(
                horizontal: 2,
              ),

              child:

              Text(
                'Hitung selisih harga beli dan harga jual serta estimasi keuntungan atau kerugian berdasarkan modal dan kurs.',
                style:

                TextStyle(
                  fontSize: 15,
                  height: 1.45,

                  color:
                  Color(0xFF222222),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width:
              double.infinity,

              padding:

              const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                12,
              ),

              decoration:

              BoxDecoration(
                color:
                const Color(0xFFFFFCFA),
                borderRadius:
                BorderRadius.circular(10),
                border:

                Border.all(
                  color:
                  const Color(0xFFE6CBB8),
                  width: 1,
                ),
              ),

              child:

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  Row(
                    children:[
                      const Icon(
                        Icons.input_outlined,
                        color:
                        Color(0xFFF7931E),
                        size: 19,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(
                        'Input Perhitungan',
                        style:

                        TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildInputField(
                    controller:
                    _modalController,

                    label:
                    'Modal (IDR)',
                    hint:
                    'Cnth : 100.000.000',

                    keyboardType:
                    TextInputType.number,
                    allowDecimal:
                    false,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInputField(
                    controller:
                    _kursController,

                    label:
                    'Kurs (IDR)',
                    hint:
                    'Cnth : 16.000',

                    keyboardType:
                    TextInputType.number,

                    allowDecimal:
                    false,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInputField(
                    controller:
                    _hargaBeliController,

                    label:
                    'Harga Beli',
                    hint:
                    'Cnth : 4.300',

                    keyboardType:

                    const TextInputType.numberWithOptions(
                      decimal:true,
                    ),

                    allowDecimal:
                    true,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildInputField(

                    controller:
                    _hargaJualController,

                    label:
                    'Harga Jual',
                    hint:
                    'Cnth: 4.302',

                    keyboardType:

                    const TextInputType.numberWithOptions(
                      decimal:true,
                    ),

                    allowDecimal:
                    true,

                  ),

                  const SizedBox(
                    height:12,
                  ),

                  Container(
                    width:
                    double.infinity,

                    padding:

                    const EdgeInsets.symmetric(
                      horizontal:10,
                      vertical:9,
                    ),

                    decoration:

                    BoxDecoration(
                      color:
                      const Color(0xFFFFF4E5),
                      borderRadius:
                      BorderRadius.circular(7),
                      border:

                      Border.all(
                        color:
                        const Color(0xFFF3C28D),
                      ),
                    ),

                    child:

                    Row(
                      children:[

                        const Icon(
                          Icons.lock_outline,
                          color:
                          Color(0xFFF7931E),
                          size:18,
                        ),

                        const SizedBox(
                          width:8,
                        ),

                        const Expanded(
                          child:

                          Text(
                            'TOz',

                            style:

                            TextStyle(
                              fontSize:14,
                              fontWeight:
                              FontWeight.bold,

                              color:
                              Color(0xFF5A4638),
                            ),
                          ),
                        ),

                        Text(
                          _formatTwoDecimals(
                            _toz,
                          ),
                          style:

                          const TextStyle(
                            fontSize:14,
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

            const SizedBox(
              height:10,
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal:10,
              ),

              child:

              SizedBox(
                width:
                double.infinity,
                height: 44,

                child:

                ElevatedButton(
                  onPressed:
                  _calculate,

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

                  child:

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children:[

                      Icon(
                        Icons.calculate_outlined,
                        size:19,
                      ),

                      SizedBox(
                        width:8,
                      ),

                      Text(
                        'Hitung',
                        style:

                        TextStyle(
                          fontSize:14,
                          fontWeight:

                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height:14,
            ),

            Padding(
              padding:

              const EdgeInsets.symmetric(
                horizontal:10,
              ),

              child:

              SizedBox(
                width:
                double.infinity,
                height: 34,

                child:
                OutlinedButton(
                  onPressed:
                  _reset,

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

                  child:

                  const Text(
                    'Reset',
                    style:

                    TextStyle(
                      fontSize:14,
                      fontWeight:

                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height:10,

            ),
          ],
        ),
      ),
    );
  }
}