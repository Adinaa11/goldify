import 'package:flutter/material.dart';

import '../models/pivot_model.dart';
import '../repositories/pivot_repository.dart';

class PivotViewModel extends ChangeNotifier {

  final PivotRepository repository;

  PivotViewModel(
    this.repository,
  );

  bool isLoading = false;

  String? errorMessage;
  String? dataDate;

  double? open;
  double? high;
  double? low;
  double? close;

  Future<void> loadData({
    String? date,
  }) async {

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try{
      final data =
          await repository.getLatestGoldData(
            date: date,
          );

      open =
          _toDouble(
            data['open'],
          );

      high =
          _toDouble(
            data['high'],
          );

      low =
          _toDouble(
            data['low'],
          );

      close =
          _toDouble(
            data['close'],
          );

      dataDate =
          date ??
          data['tanggal']?.toString();

      if(open == null ||
          high == null ||
          low == null ||
          close == null){
        throw Exception(
          'Data Open, High, Low, Close tidak tersedia',
        );
      }

      isLoading = false;

    }catch(e){

      isLoading = false;

      errorMessage =
          'Tidak dapat mengambil data emas.\n'
          'Periksa koneksi internet atau API.';

    }

    notifyListeners();
  }

  void loadInitialData(
    Map<String,dynamic> data,
  ){

    open =
        _toDouble(
          data['open'],
        );

    high =
        _toDouble(
          data['high'],
        );

    low =
        _toDouble(
          data['low'],
        );

    close =
        _toDouble(
          data['close'],
        );

    dataDate =
        data['dataDate']?.toString()
        ??
        data['date']?.toString();

    notifyListeners();
  }

  PivotModel? calculate(){

    if(
      high == null ||
      low == null ||
      close == null
    ){
      errorMessage =
          'Silakan isi data dengan lengkap.';

      notifyListeners();
      return null;
    }

    if(high! <= low!){

      errorMessage =
          'Harga High harus lebih besar dari Harga Low.';

      notifyListeners();
      return null;
    }

    final double pp =
        (high! + low! + close!) / 3;

    final double r1 =
        (2 * pp) - low!;

    final double r2 =
        pp + (high! - low!);

    final double r3 =
        high! + 2 * (pp - low!);

    final double r4 =
        r3 + (r2 - r1);

    final double s1 =
        (2 * pp) - high!;

    final double s2 =
        pp - (high! - low!);

    final double s3 =
        low! - 2 * (high! - pp);

    final double s4 =
        s3 - (r1 - s1);

    return PivotModel(
      open:
          open ?? 0,
      high:
          high!,
      low:
          low!,
      close:
          close!,

      pivot:
          pp,

      r1:
          r1,
      r2:
          r2,
      r3:
          r3,
      r4:
          r4,


      s1:
          s1,
      s2:
          s2,
      s3:
          s3,
      s4:
          s4,

      date:
          dataDate,
    );
  }

  Future<bool> saveHistory(
    PivotModel data,
  ) async {

    return await repository.saveHistory(
      data,
    );
  }

  double? _toDouble(
    dynamic value,
  ){

    if(value == null){
      return null;
    }

    return double.tryParse(
      value.toString()
      .replaceAll(',', '.'),
    );
  }
}