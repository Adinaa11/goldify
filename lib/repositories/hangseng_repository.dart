import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/hangseng_model.dart';

class HangsengRepository {

  final supabase =
      Supabase.instance.client;

  // SIMPAN HISTORY HANGSENG
  Future<void> saveHistory(
      HangsengModel data
  ) async {

    final user =
        supabase.auth.currentUser;

    if(user == null){

      throw Exception(
        "User belum login",
      );
    }

    await supabase
        .from('history')
        .insert({

          'user_id':
          user.id,

          'type':
          'hangseng',

          'input':{
            'open':
            data.open,

            'high':
            data.high,

            'low':
            data.low,

            'close':
            data.close,
          },

          'result':
          data.toJson(),

          'created_at':
          DateTime.now()
          .toIso8601String(),

        });
  }
}