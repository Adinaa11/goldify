import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../viewmodels/hangseng_viewmodel.dart';
import '../../repositories/hangseng_repository.dart';

import 'hangseng_result_page.dart';

class HangsengPage extends StatefulWidget {
  final Map<String,dynamic>? initialData;
  const HangsengPage({
    super.key,
    this.initialData,
  });

  @override
  State<HangsengPage> createState()
      => _HangsengPageState();

}
class _ThousandsFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ){

    String text =
        newValue.text;

    if(text.isEmpty){

      return newValue;
    }

    text =
        text.replaceAll('.', '');

    final commaCount =
        ','.allMatches(text).length;

    if(commaCount > 1){

      return oldValue;
    }

    final commaIndex =
        text.indexOf(',');

    String integerPart;
    String decimalPart = '';

    if(commaIndex >=0){

      integerPart =
          text.substring(
            0,
            commaIndex,
          );

      decimalPart =
          text.substring(
            commaIndex + 1,
          );

    }else{
      integerPart =
          text;
    }

    if(!RegExp(r'^\d*$')
        .hasMatch(integerPart)){

      return oldValue;
    }

    if(!RegExp(r'^\d*$')
        .hasMatch(decimalPart)){

      return oldValue;
    }

    final formattedInteger =

    integerPart.replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
      (match)=>'.',
    );

    String formatted =
        formattedInteger;

    if(commaIndex >=0){

      formatted +=
          ',$decimalPart';
    }

    return TextEditingValue(
      text:formatted,
      selection:
      TextSelection.collapsed(
        offset:
        formatted.length,
      ),
    );
  }
}

class _HangsengPageState
extends State<HangsengPage>{
  late HangsengViewModel viewModel;

  final TextEditingController _openController =
      TextEditingController();
  final TextEditingController _highController =
      TextEditingController();
  final TextEditingController _lowController =
      TextEditingController();
  final TextEditingController _closeController =
      TextEditingController();
  static const Color orange =
      Color(0xFFF7931E);
  static const Color darkText =
      Color(0xFF222222);
  static const Color greyText =
      Color(0xFF555555);
  static const Color fieldColor =
      Color(0xFFF7F5F3);

  String? _selectedDate;
  bool get _isRecalculate =>
      widget.initialData != null;

  @override
  void initState(){
    super.initState();

    viewModel =
        HangsengViewModel(
          HangsengRepository(),
        );

    viewModel.addListener((){
      if(!mounted) return;
      setState((){});
    });
    if(_isRecalculate){

      _loadInitialData();
    }
    else{
      _loadHangsengData();
    }
  }

  Future<void> _loadHangsengData({
    String? date,
  }) async{

    await viewModel.loadData(
      date:date,
    );

    if(!mounted)return;

    if(viewModel.errorMessage == null){

      setState((){

        _openController.text =
            _formatInitialNumber(
              viewModel.open,
            );

        _highController.text =
            _formatInitialNumber(
              viewModel.high,
            );

        _lowController.text =
            _formatInitialNumber(
              viewModel.low,
            );

        _closeController.text =
            _formatInitialNumber(
              viewModel.close,
            );
      });
    }
  }

  void _loadInitialData(){

    final d =
        widget.initialData!;

    _openController.text =
        _formatInitialNumber(
          d['open'],
        );

    _highController.text =
        _formatInitialNumber(
          d['high'],
        );

    _lowController.text =
        _formatInitialNumber(
          d['low'],
        );

    _closeController.text =
        _formatInitialNumber(
          d['close'],
        );

    viewModel.dataDate =
        d['date']?.toString()
        ??
        d['dataDate']?.toString();
  }

  String _formatInitialNumber(dynamic value){
  if(value == null){
    return '';
  }

  double? number;

  if(value is num){
    number =
        value.toDouble();
  }
  else{

    String text =
        value.toString()
            .trim();

    // format API: 25.765
    if(text.contains('.') &&
        !text.contains(',')){

      text =
          text.replaceAll('.', '');
    }

    text =
        text.replaceAll(',', '.');

    number =
        double.tryParse(text);
  }

  if(number == null){

    return value.toString();
  }

  final integer =
      number
      .toInt()
      .toString()
      .replaceAllMapped(

        RegExp(
          r'\B(?=(\d{3})+(?!\d))',
        ),
        (match)=>'.',
      );

  return integer;
}

  Future<void> _selectDate() async{

    if(viewModel.isLoading ||
        _isRecalculate){

      return;
    }

    DateTime initialDate =
        DateTime.now();

    if(viewModel.dataDate != null){

      try{

        initialDate =
            DateTime.parse(
              viewModel.dataDate!
                  .substring(0,10),
            );
      }catch(_){}
    }

    final picked =
        await showDatePicker(

      context:context,
      initialDate:
      initialDate,

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime.now(),

      builder:(context,child){
        return Theme(

          data:
          Theme.of(context)
              .copyWith(
            colorScheme:
            const ColorScheme.light(
              primary:
              orange,
              onPrimary:
              Colors.white,
              surface:
              Colors.white,
              onSurface:
              darkText,
            ),
          ),

          child:
          child!,
        );
      },
    );

    if(picked == null)
      return;
    final date =
    '${picked.year}-'
        '${picked.month.toString().padLeft(2,'0')}-'
        '${picked.day.toString().padLeft(2,'0')}';

    _selectedDate =
        date;

    await _loadHangsengData(
      date:date,
    );
  }

  String _formatDate(String? date){
    if(date == null ||
        date.isEmpty){

      return '-';
    }

    final clean =
        date.substring(0,10);

    final parts =
        clean.split('-');

    if(parts.length !=3){

      return date;
    }

    return
        '${parts[2]}/${parts[1]}/${parts[0]}';

  }

  double? _parseNumber(
      String value
      ){

    if(value.trim().isEmpty){
      return null;
    }

    String text =
        value.trim();

    if(text.contains(',')){

      text =
          text
          .replaceAll('.', '')
          .replaceAll(',', '.');
    }
    else{

      text =
          text.replaceAll('.', '');
    }
    return double.tryParse(text);
  }

  bool get _hasHangsengData {
    return
        _openController.text.isNotEmpty &&
        _highController.text.isNotEmpty &&
        _lowController.text.isNotEmpty &&
        _closeController.text.isNotEmpty;
  }

  Future<void> _calculateHangseng() async {
    final open =
        _parseNumber(
          _openController.text,
        );

    final high =
        _parseNumber(
          _highController.text,
        );

    final low =
        _parseNumber(
          _lowController.text,
        );

    final close =
        _parseNumber(
          _closeController.text,
        );

    if(!_hasHangsengData ||
        high == null ||
        low == null ||
        close == null){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Data Hangseng belum lengkap.",
          ),

          backgroundColor:
          orange,
        ),
      );

      return;
    }

    if(high <= low){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Harga High harus lebih besar dari Harga Low.",
          ),

          backgroundColor:
          orange,
        ),
      );

      return;
    }

    final result =
        viewModel.calculate(

          open: open ?? 0,
          high: high,
          low: low,
          close: close,
          date:
          viewModel.dataDate,
        );

    await viewModel.saveHistory(
      result,
    );

    if(!mounted)
      return;

    Navigator.push(
      context,

      MaterialPageRoute(
        builder:(context)=>

        HangsengResultPage(

          open: open ?? 0,
          high: high,
          low: low,
          close: close,

          hasDecimalInput:

          _openController.text.contains(',') ||
          _highController.text.contains(',') ||
          _lowController.text.contains(',') ||
          _closeController.text.contains(','),

          openInput:
          _openController.text,

          highInput:
          _highController.text,

          lowInput:
          _lowController.text,

          closeInput:
          _closeController.text,

          dataDate:
          viewModel.dataDate,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {

    if(_isRecalculate)
      return;

    await _loadHangsengData(
      date:
      _selectedDate,
    );

    if(!mounted)
      return;

    if(viewModel.errorMessage == null){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Data Hangseng berhasil diperbarui.",
          ),

          backgroundColor:
          orange,
        ),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly=false,

  }){

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom:14,
      ),

      child:

      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children:[

          Text(
            label,
            style:
            const TextStyle(

              fontFamily:
              'monospace',
              fontSize: 12,
              fontWeight:
              FontWeight.w500,
              color:
              darkText,
            ),
          ),

          const SizedBox(
            height:5,
          ),

          Container(
            height: 52,

            decoration:

            BoxDecoration(
              color:
              readOnly ?

              const Color(0xFFF1EFED) :
              fieldColor,

              border:

              Border(
                bottom:

                BorderSide(
                  color:
                  readOnly ?
                  orange :
                  Colors.grey.shade600,
                  width: 1.2,
                ),
              ),
            ),

            child:

            TextField(
              controller:
              controller,
              readOnly:
              readOnly,

              keyboardType:

              const TextInputType.numberWithOptions(

                decimal:true,
              ),

              inputFormatters:
              readOnly ?
              null :
              [
                _ThousandsFormatter(),
              ],

              onChanged:(value){

                setState((){});
              },

              style:

              TextStyle(
                fontFamily:
                'monospace',
                fontSize: 15,
                fontWeight:
                readOnly ?
                FontWeight.w600 :
                FontWeight.normal,
              ),

              decoration:

              InputDecoration(
                border:
                InputBorder.none,

                contentPadding:

                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),

                hintText:
                hint,
                hintStyle:

                const TextStyle(
                  fontFamily: 'monospace',
                  fontSize:  14,
                  color:
                  Colors.grey,
                ),

                suffixIcon:
                readOnly ?

                const Padding(

                  padding:
                  EdgeInsets.only(
                    right:12,
                  ),

                  child:

                  Icon(
                    Icons.lock_outline,
                    color: orange,
                    size: 18,

                  ),
                ) :
                null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
    Widget build(BuildContext context) {

      return AnimatedBuilder(

        animation:
        viewModel,

        builder:(context,child){

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
                alpha:0.20,
              ),

              leading:
              IconButton(
                icon:
                const Icon(

                  Icons.arrow_back_ios_new,
                  color: orange,
                  size: 21,
                ),

                onPressed:
                ()=>Navigator.pop(context),
              ),

              titleSpacing: 0,

              title:
              RichText(

                text:
                const TextSpan(

                  style:
                  TextStyle(

                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    darkText,
                  ),

                  children:[
                    TextSpan(

                      text:
                      "Kalkulator ",
                    ),

                    TextSpan(
                      text:
                      "Hangseng",
                      style:
                      TextStyle(

                        color:
                        orange,
                      ),
                    ),
                  ],
                ),
              ),

              actions:[

                if(!_isRecalculate)

                IconButton(
                  tooltip:
                  "Refresh Data",
                  onPressed:
                  viewModel.isLoading ?
                  null:
                  _refreshData,

                  icon:
                  const Icon(
                    Icons.refresh,
                    color: orange,
                    size: 23,

                  ),
                ),

                const SizedBox(
                  width:4,
                ),
              ],
            ),

            body:

            SingleChildScrollView(
              padding:
              const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                40,
              ),

              child:

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children:[

                  const Padding(

                    padding:
                    EdgeInsets.only(
                      right:10,
                    ),

                    child:

                    Text(
                      "Hitung titik keseimbangan atau level harga acuan berdasarkan pergerakan indeks Hangseng pada periode sebelumnya.",

                      style:

                      TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: darkText,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:18,
                  ),

                  Align(
                    alignment:
                    Alignment.centerLeft,

                    child:
                    IntrinsicWidth(
                      child:

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:10,
                          vertical:8,
                        ),

                        decoration:

                        BoxDecoration(
                          color:
                          const Color(
                            0xFFFFF7ED,
                          ),

                          borderRadius:
                          BorderRadius.circular(7),
                          border:

                          Border.all(
                            color:
                            const Color(
                              0xFFF3D2B0,
                            ),
                          ),
                        ),

                        child:

                        Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children:[
                            const Icon(
                              Icons.cloud_download_outlined,

                              color: orange,
                              size: 25,
                            ),

                            const SizedBox(
                              width:8,
                            ),

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children:[

                                const Text(
                                  "Data Hangseng",
                                  style:

                                  TextStyle(
                                    fontSize: 15,
                                    
                                    fontWeight:
                                    FontWeight.bold,

                                    color:
                                    darkText,
                                  ),
                                ),

                                const SizedBox(
                                  height:4,
                                ),

                                Row(
                                  children:[

                                    Text(
                                      _isRecalculate ?
                                      "Data dari riwayat" :

                                      viewModel.isLoading ?
                                      "Mengambil data terbaru..." :

                                      viewModel.errorMessage
                                      ??
                                      "Tanggal: ${_formatDate(viewModel.dataDate)}",

                                      style:

                                      TextStyle(
                                        fontSize: 13,
                                      
                                        color:

                                        viewModel.errorMessage != null ?

                                        Colors.red :

                                        greyText,
                                      ),
                                    ),

                                    if(!_isRecalculate &&
                                        !viewModel.isLoading &&
                                        viewModel.errorMessage == null)

                                    const SizedBox(
                                      width:8,
                                    ),

                                    if(!_isRecalculate &&
                                        !viewModel.isLoading &&
                                        viewModel.errorMessage == null)

                                    GestureDetector(
                                      onTap: _selectDate,

                                      child:

                                      const Icon(
                                        Icons.calendar_month,

                                        color: orange,
                                        size:20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:10,
                  ),

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.fromLTRB(
                      10,
                      10,
                      8,
                      10,
                    ),

                    decoration:

                    BoxDecoration(

                      color:
                      const Color(
                        0xFFFFFCFA,
                      ),

                      borderRadius:
                      BorderRadius.circular(9),
                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFFE6D7CA,
                        ),
                      ),
                    ),

                    child:

                    Container(
                      decoration:
                      const BoxDecoration(
                        border:
                        Border( left:
                          BorderSide(
                            color: orange,
                            width: 3,
                          ),
                        ),
                      ),

                      padding:
                      const EdgeInsets.only(
                        left:9,
                      ),

                      child:

                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children:[

                          const Row(
                            children:[

                              Icon(
                                Icons.input,
                                color: orange,
                                size: 19,

                              ),

                              SizedBox(
                                width:8,
                              ),

                              Text(
                                "Data Perhitungan",
                                style:
                                TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,

                                  color:
                                  darkText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height:18,
                          ),

                          _buildInputField(
                            label: "Harga Open",
                            hint: "Masukkan harga Open",

                            controller:
                            _openController,

                          ),

                          _buildInputField(
                            label: "Harga High",
                            hint: "Menunggu data...",

                            controller:
                            _highController,

                            readOnly: false,
                          ),

                          _buildInputField(
                            label: "Harga Low",
                            hint: "Menunggu data...",

                            controller:
                            _lowController,
                            readOnly: false,
                          ),

                          _buildInputField(
                            label: "Harga Close",
                            hint: "Menunggu data...",
                            controller:
                            _closeController,

                            readOnly: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:20,
                  ),

                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:8,
                    ),

                    child:

                    SizedBox(
                      width:
                      double.infinity,

                      height: 42,
                      child:

                      ElevatedButton(

                        onPressed:
                        viewModel.isLoading ||
                        !_hasHangsengData ?

                        null :
                        _calculateHangseng,

                        style:

                        ElevatedButton.styleFrom(

                          backgroundColor:
                          orange,

                          disabledBackgroundColor:
                          Colors.grey.shade300,

                          foregroundColor:
                          Colors.white,

                          elevation: 0,
                          
                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(6),
                          ),
                        ),

                        child:

                        const Row(

                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children:[

                            Icon(
                              Icons.calculate,
                              size: 19,
                            
                            ),

                            SizedBox(
                              width:8,
                            ),

                            Text(
                              "Hitung",
                              style:
                              TextStyle(
                                fontFamily:
                                'monospace',

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

                  const SizedBox(
                    height:30,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }