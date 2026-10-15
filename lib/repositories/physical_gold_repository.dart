import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/physical_gold_model.dart';

class PhysicalGoldRepository {

  final SupabaseClient supabase =
      Supabase.instance.client;

  Future<void> saveHistory(
    PhysicalGoldModel data,
  ) async {

    final user =
        supabase.auth.currentUser;

    if(user == null){

      debugPrint(
        "USER BELUM LOGIN",
      );
      return;
    }

    try{
      final response =
      await supabase

      .from('history')

      .insert({
        'user_id':

        user.id,
        'type':
        'emas_fisik',
        'input':

        data.toInputJson(),

        'result':

        data.toResultJson(),

        'created_at':

        DateTime.now()
        .toIso8601String(),
      })
      .select();

      debugPrint(

        "DATA EMAS FISIK MASUK: $response",
      );
    }

    catch(e){

      debugPrint(
        "ERROR INSERT EMAS FISIK: $e",

      );
    }
  }
}