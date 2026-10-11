class PhysicalGoldModel {

  final double modal;
  final double kurs;
  final double hargaBeli;
  final double hargaJual;

  final double step1;
  final double step2;
  final double step3;
  final double step4;
  final double step5;

  PhysicalGoldModel({

    required this.modal,
    required this.kurs,
    required this.hargaBeli,
    required this.hargaJual,
    required this.step1,
    required this.step2,
    required this.step3,
    required this.step4,
    required this.step5,
  });

  String get status {

    if(step5 >= 0){

      return 'profit';
    }

    return 'loss';
  }

  Map<String,dynamic> toInputJson(){
    return {
      'modal': modal,
      'kurs': kurs,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
    };
  }

  Map<String,dynamic> toResultJson(){

    return {

      'step1': step1,
      'step2': step2,
      'step3': step3,
      'step4': step4,
      'step5': step5,

      'status': status,
    };
  }
}