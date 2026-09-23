import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pivot_model.dart';
import '../services/market_service.dart';

class PivotRepository {

  Future<Map<String,dynamic>> getLatestGoldData({
    String? date,
  }) async {

    final data =
        await MarketService.getLatestGoldData(
          date: date,
        );
    return data;
  }

  Future<bool> saveHistory(
    PivotModel data,
  ) async {

    final supabase =
        Supabase.instance.client;

    final user =
        supabase.auth.currentUser;

    if(user == null){

      return false;
    }

    try{
      await supabase
          .from('history')
          .insert({

        'user_id':
            user.id,
        'type':
            'pivot',

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
            data.toResultJson(),

        'created_at':
            DateTime.now()
            .toIso8601String(),
      });

      return true;

    }catch(e){

      return false;
    }
  }
}