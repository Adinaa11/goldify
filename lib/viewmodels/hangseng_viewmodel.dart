import 'package:flutter/material.dart';

import '../models/hangseng_model.dart';
import '../repositories/hangseng_repository.dart';
import '../services/market_service.dart';

class HangsengViewModel extends ChangeNotifier {

  final HangsengRepository repository;

  HangsengViewModel(
    this.repository,
  );

  bool isLoading = false;

  String? errorMessage;
  String? dataDate;

  // DATA HARGA HANGSENG
  double? open;
  double? high;
  double? low;
  double? close;

  // AMBIL DATA HANGSENG
  Future<void> loadData({
    String? date,
  }) async {

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data =
          await MarketService
              .getLatestHangsengData(
                date: date,
              );

      // SIMPAN DATA HARGA
      open =
          _parseDouble(
            data['open'],
          );

      high =
          _parseDouble(
            data['high'],
          );

      low =
          _parseDouble(
            data['low'],
          );

      close =
          _parseDouble(
            data['close'],
          );

      // SIMPAN TANGGAL
      dataDate =
          date ??
          data['tanggal']?.toString()
          ??
          data['date']?.toString();

      if(
        high == null ||
        low == null ||
        close == null
      ){

        throw Exception(
          "Data Hangseng tidak lengkap",
        );
      }
    } catch(e){
      errorMessage =
          e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  double? _parseDouble(dynamic value){

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
          text
          .replaceAll('.', '')
          .replaceAll(',', '.');

    }
    else{

      text =
          text.replaceAll(',', '');
    }

    return double.tryParse(text);
  }

  // HITUNG PIVOT HANGSENG
  HangsengModel calculate({

    required double open,
    required double high,
    required double low,
    required double close,

    String? date,
  }){

    final pp =
        (high + low + close) / 3;

    final r1 =
        (2 * pp) - low;

    final s1 =
        (2 * pp) - high;

    final r2 =
        pp + (high - low);

    final s2 =
        pp - (high - low);

    final r3 =
        high + 2 * (pp - low);

    final s3 =
        low - 2 * (high - pp);

    final r4 =
        r3 + (r2 - r1);

    final s4 =
        s3 - (r1 - s1);

    return HangsengModel(

      open: open,
      high: high,
      low: low,
      close: close,

      pp: pp,

      r1: r1,
      r2: r2,
      r3: r3,
      r4: r4,

      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,

      date: date,
    );
  }

  // SIMPAN HISTORY
  Future<void> saveHistory(
      HangsengModel data
  ) async {

    await repository.saveHistory(
      data,
    );
  }
}