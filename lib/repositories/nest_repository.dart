import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/nest_model.dart';
import '../services/market_service.dart';


class NestRepository {

  Future<Map<String,dynamic>> getLatestGoldData({
    String? date,

  }) async {

    final data =

    await MarketService
        .getLatestGoldData(
          date: date,
        );

    return data;
  }

  // SIMPAN HISTORY
  Future<void> saveHistory(
    NestModel data,

  ) async {

    final supabase =
        Supabase.instance.client;

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
                'nest',

            'input':{

              'open':
                  data.open ?? 0,
              'close':
                  data.close,
              'date':
                  data.date,
            },

            'result':{

              'status':
                  data.status,
              'open':
                  data.open,
              'close':
                  data.close,
            },
            
            'created_at':

                DateTime.now()
                .toIso8601String(),
          })

          .select();

      debugPrint(
        "DATA NEST MASUK: $response",
      );
    }

    catch(e){

      debugPrint(
        "ERROR INSERT NEST: $e",
      );
    }
  }
}