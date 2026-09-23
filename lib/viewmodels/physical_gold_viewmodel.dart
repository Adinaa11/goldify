import 'package:flutter/material.dart';

import '../models/physical_gold_model.dart';
import '../repositories/physical_gold_repository.dart';

class PhysicalGoldViewModel extends ChangeNotifier {

  final PhysicalGoldRepository repository;

  PhysicalGoldViewModel(
    this.repository,
  );

  static const double toz = 31.1;

  String? errorMessage;

  bool isLoading = false;

  Future<PhysicalGoldModel?> calculate({

    required String modalText,
    required String kursText,
    required String hargaBeliText,
    required String hargaJualText,

  }) async {

    final double modal =
        _parseNumber(
          modalText,
        );

    final double kurs =
        _parseNumber(
          kursText,
        );

    final double hargaBeli =
        _parseNumber(
          hargaBeliText,
        );

    final double hargaJual =
        _parseNumber(
          hargaJualText,
        );

    if(
      modal <= 0 ||
      kurs <= 0 ||
      hargaBeli <= 0 ||
      hargaJual <= 0
    ){

      errorMessage =
          'Silakan isi Modal, Kurs, Harga Beli, dan Harga Jual.';

      notifyListeners();
      return null;
    }

    // STEP 1
    final double rawStep1 =
        (hargaBeli * kurs) / toz;

    final double step1 =
        _truncateInteger(
          rawStep1,
        );

    if(step1 <= 0){
      errorMessage =
          'Hasil Harga Beli tidak valid.';

      notifyListeners();
      return null;
    }

    // STEP 2
    final double rawStep2 =
        (hargaJual * kurs) / toz;

    final double step2 =
        _truncateInteger(
          rawStep2,
        );

    // STEP 3
    final double step3 =
        _truncateInteger(
          step2 - step1,
        );

    // STEP 4
    final double step4 =
        _truncateTo2(
          modal / step1,
        );

    // STEP 5
    final double rawStep5 =
        step3 * step4;

    final double step5 =
        _truncateInteger(
          rawStep5,
        );

    final result =
        PhysicalGoldModel(

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

    await repository.saveHistory(
      result,
    );

    return result;
  }

  double _parseNumber(
    String value,
  ){

    String text =
        value.trim();

    if(text.isEmpty){

      return 0;
    }

    text =
        text
        .replaceAll(
          'Rp',
          '',
        )
        .replaceAll(
          'rp',
          '',
        )
        .replaceAll(
          ' ',
          '',
        );

    if(text.contains('.')){

      text =
          text.replaceAll(
            '.',
            '',
          );
    }

    if(text.contains(',')){

      text =
          text.replaceAll(
            ',',
            '.',
          );
    }

    return double.tryParse(text)
        ??0;
  }

  double _truncateInteger(
    double value,
  ){

    return value.truncateToDouble();
  }

  double _truncateTo2(
    double value,
  ){

    return
    (value * 100)
    .truncateToDouble() / 100;
  }
}