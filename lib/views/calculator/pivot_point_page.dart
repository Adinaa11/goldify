import 'package:flutter/material.dart';

import '../../models/pivot_model.dart';
import '../../repositories/pivot_repository.dart';
import '../../viewmodels/pivot_viewmodel.dart';

import 'pivot_result_page.dart';



class PivotPointPage extends StatefulWidget {

  final Map<String,dynamic>? initialData;


  const PivotPointPage({
    super.key,
    this.initialData,
  });



  @override
  State<PivotPointPage> createState()
      => _PivotPointPageState();

}




class _PivotPointPageState
    extends State<PivotPointPage>{



  late PivotViewModel viewModel;



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
        PivotViewModel(
          PivotRepository(),
        );


    viewModel.addListener((){

      if(!mounted) return;

      setState((){});

    });



    if(_isRecalculate){

      _loadInitialData();

    }
    else{

      _loadGoldData();

    }

  }






  void _loadInitialData(){


    final data =
        widget.initialData!;



    _openController.text =
        _formatInitialNumber(
          data['open'],
        );


    _highController.text =
        _formatInitialNumber(
          data['high'],
        );


    _lowController.text =
        _formatInitialNumber(
          data['low'],
        );


    _closeController.text =
        _formatInitialNumber(
          data['close'],
        );



    viewModel.loadInitialData(
      data,
    );


  }






  Future<void> _loadGoldData({
    String? date,
  }) async {


    await viewModel.loadData(
      date: date,
    );



    if(!mounted) return;



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

  }







  String _formatInitialNumber(
    dynamic value,
  ){


    if(value == null){

      return '';

    }



    if(value is num){


      if(value ==
          value.truncateToDouble()){


        return value
            .toInt()
            .toString();


      }


      return value.toString();

    }




    final number =
        double.tryParse(
          value.toString(),
        );



    if(number == null){

      return value.toString();

    }



    if(number ==
        number.truncateToDouble()){


      return number
          .toInt()
          .toString();

    }



    return number.toString();

  }






  @override
  void dispose(){


    _openController.dispose();

    _highController.dispose();

    _lowController.dispose();

    _closeController.dispose();


    viewModel.dispose();


    super.dispose();

  }







  Future<void> _selectDate() async {


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

      context:
          context,

      initialDate:
          initialDate,

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime.now(),

      helpText:
          'Pilih tanggal data emas',

      cancelText:
          'Batal',

      confirmText:
          'Pilih',

      builder:
      (context,child){

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

    await _loadGoldData(
      date: date,
    );
  }

  String _formatDate(String? date){

    if(date == null || date.isEmpty){
      return '-';
    }


    final clean =
        date.substring(0,10);


    final parts =
        clean.split('-');


    if(parts.length != 3){
      return date;
    }


    return
        '${parts[2]}/${parts[1]}/${parts[0]}';

  }




  bool get _hasGoldData{

    return _highController.text.isNotEmpty &&
        _lowController.text.isNotEmpty &&
        _closeController.text.isNotEmpty;

  }





  Future<void> _calculatePivot() async {


    final PivotModel? result =
        viewModel.calculate();



    if(result == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:

          Text(
            viewModel.errorMessage ??
            'Data tidak valid.',
          ),

          backgroundColor:
          orange,

        ),

      );


      return;

    }




    final bool saved =
        await viewModel.saveHistory(
          result,
        );




    if(!mounted) return;




    if(!saved){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            'Gagal menyimpan data ke database',
          ),

          backgroundColor:
          Colors.red,

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

        builder:(context)

        => PivotResultPage(

          open:
          result.open,


          high:
          result.high,


          low:
          result.low,


          close:
          result.close,


          hasDecimalInput:
          hasDecimalInput,


          dataDate:
          result.date,


        ),

      ),

    );


  }






  Future<void> _refreshData() async {


    if(_isRecalculate){

      return;

    }



    await _loadGoldData(
      date:
      _selectedDate,
    );



    if(!mounted) return;



    if(viewModel.errorMessage == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            'Data emas berhasil diperbarui.',
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

              fontSize:
              12,

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

            height:
            52,


            decoration:

            BoxDecoration(

              color:
              fieldColor,


              border:

              Border(

                bottom:

                BorderSide(

                  color:
                  Colors.grey.shade600,

                  width:
                  1.2,

                ),

              ),

            ),



            child:

            TextField(

              controller:
              controller,


              keyboardType:

              const TextInputType
                  .numberWithOptions(
                decimal:true,
              ),



              onChanged:(value){

                setState((){});

              },



              style:

              const TextStyle(

                fontFamily:
                'monospace',

                fontSize:
                15,

                color:
                darkText,

              ),



              decoration:

              InputDecoration(

                border:
                InputBorder.none,


                contentPadding:

                const EdgeInsets.symmetric(

                  horizontal:
                  10,

                  vertical:
                  14,

                ),



                hintText:
                hint,


                hintStyle:

                const TextStyle(

                  fontFamily:
                  'monospace',

                  fontSize:
                  14,

                  color:
                  Colors.grey,

                ),


                suffixIcon:

                viewModel.isLoading

                ?

                const Padding(

                  padding:
                  EdgeInsets.all(16),

                  child:

                  SizedBox(

                    width:
                    16,

                    height:
                    16,


                    child:

                    CircularProgressIndicator(

                      strokeWidth:
                      2,

                      color:
                      orange,

                    ),

                  ),

                ):
                null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor:
      Colors.white,


      appBar:

      AppBar(

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation:
        4,

        shadowColor:
        Colors.black.withValues(
          alpha:0.20,
        ),


        leading:

        IconButton(

          icon:

          const Icon(

            Icons.arrow_back_ios_new,

            color:
            orange,

            size:
            21,

          ),


          onPressed:(){

            Navigator.pop(context);

          },

        ),


        titleSpacing:
        0,


        title:

        RichText(

          text:

          const TextSpan(

            style:

            TextStyle(

              fontSize:
              16,

              fontWeight:
              FontWeight.bold,

              color:
              darkText,

            ),


            children:[


              TextSpan(

                text:
                'Kalkulator ',

              ),


              TextSpan(

                text:
                'Pivot',

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
            'Refresh Data',


            onPressed:

            viewModel.isLoading

            ?

            null

            :

            _refreshData,


            icon:

            const Icon(

              Icons.refresh,

              color:
              orange,

              size:
              23,

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

                'Hitung titik keseimbangan atau level harga acuan berdasarkan pergerakan harga pada periode sebelumnya.',


                style:

                TextStyle(

                  fontSize:
                  14,

                  height:
                  1.45,

                  color:
                  darkText,

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

                    horizontal: 10,
                    vertical: 8,
                  ),

                  decoration:

                  BoxDecoration(
                    color:
                    const Color(0xFFFFF7ED),
                    borderRadius:
                    BorderRadius.circular(7),
                    border:

                    Border.all(
                      color:
                      const Color(0xFFF3D2B0),
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
                            'Data LGD Daily',
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
                                'Data dari riwayat' :

                                viewModel.isLoading ?
                                'Mengambil data terbaru...' :
                                viewModel.errorMessage ??
                                'Tanggal: ${_formatDate(viewModel.dataDate)}',

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
                                onTap:
                                _selectDate,
                                child:

                                const Icon(
                                  Icons.calendar_month,
                                  color:orange,
                                  size: 20,
                                
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
                const Color(0xFFFFFCFA),

                borderRadius:
                BorderRadius.circular(9),
                border:

                Border.all(
                  color:
                  const Color(0xFFE6D7CA),
                ),
              ),

              child:

              Column(
                children:[

                  _buildInputField(
                    label:
                    'Harga Open',
                    hint:
                    'Masukkan harga Open...',
                    controller:
                    _openController,
                  ),

                  _buildInputField(
                    label:
                    'Harga High',
                    hint:
                    'Menunggu data...',
                    controller:
                    _highController,
                  ),

                  _buildInputField(
                    label:
                    'Harga Low',
                    hint:
                    'Menunggu data...',
                    controller:
                    _lowController,
                  ),

                  _buildInputField(
                    label:
                    'Harga Close',
                    hint:
                    'Menunggu data...',

                    controller:
                    _closeController,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:20,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 42, 
      
              child:

              ElevatedButton(
                onPressed:
                viewModel.isLoading ||
                !_hasGoldData ?

                null :
                _calculatePivot,

                style:

                ElevatedButton.styleFrom(
                  backgroundColor:
                  orange,
                  foregroundColor:
                  Colors.white,

                  elevation: 0,
                ),

                child:

                const Text(
                  'Hitung',
                  style:

                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}