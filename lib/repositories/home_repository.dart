import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/market_service.dart';

class HomeRepository {
  final SupabaseClient supabase;

  HomeRepository({
    SupabaseClient? supabase,
  }) : supabase =
            supabase ?? Supabase.instance.client;

  Future<String> getUserName() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return '';
    }

    try {
      // Ambil nama TERBARU langsung dari tabel profiles
      final profile = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      String fullName = '';

      if (profile != null &&
          profile['name'] != null &&
          profile['name']
              .toString()
              .trim()
              .isNotEmpty) {
        fullName =
            profile['name'].toString().trim();
      }

      if (fullName.isNotEmpty) {
        return fullName
            .split(RegExp(r'\s+'))
            .first;
      }

      return '';
    } catch (e) {
      // Error ditangani di ViewModel.
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>>
      getHistoricalGoldData() async {
    return await MarketService
        .getHistoricalGoldData();
  }
}