import 'package:flutter/material.dart';

import '../models/nest_model.dart';
import '../repositories/nest_repository.dart';

class NestViewModel extends ChangeNotifier {

  final NestRepository repository;

  NestViewModel(
    this.repository,
  );

  bool isLoading = false;
  String? errorMessage;
  String? dataDate;
  double? open;
  double? close;

  Future<void> loadData({
    String? date,

  }) async {

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final Map<String,dynamic> data =
      await repository.getLatestGoldData(
        date: date,
      );

      open =
      _parseNumber(

        data['open'],
      );

      close =

      _parseNumber(
        data['close'],

      );

      dataDate =

      date ??

      data['tanggal']?.toString();

      if(close == null){

        throw Exception(

          "Data Close tidak tersedia.",

        );
      }

    }
    catch(e){

      errorMessage =

      e.toString();
    }

    isLoading = false;

    notifyListeners();
  }

  void loadInitialData(
    Map<String,dynamic> data,

  ){
    open =
    _parseNumber(
      data['open'],
    );

    close =
    _parseNumber(

      data['close'],
    );

    dataDate =
    data['dataDate']?.toString()
    ??
    data['date']?.toString();

    notifyListeners();
  }

  NestModel calculate(){
    String status;

    if(open == null){

      status = "-";
    }
    else if(open! < close!){

      status = "BUY";
    }
    else if(open! > close!){

      status = "SELL";

    }
    else{
      status = "BUY / SELL";
    }

    return NestModel(

      open: open,
      close: close!,
      status: status,
      date: dataDate,
    );
  }

  Future<void> saveHistory(
    NestModel data,
  ) async{

    await repository.saveHistory(
      data,
    );
  }

  double? _parseNumber(
    dynamic value,
  ){

    if(value == null){

      return null;
    }

    if(value is num){

      return value.toDouble();
    }

    String text =
    value.toString()
    .trim();

    if(text.isEmpty){

      return null;
    }

    if(text.contains(',')){
      text =

      text.replaceAll(
        '.',
        '',
      )
      .replaceAll(
        ',',
        '.',
      );
    }

    return double.tryParse(
      text,
    );
  }
}