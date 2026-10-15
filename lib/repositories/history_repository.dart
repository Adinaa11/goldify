import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_model.dart';

class HistoryRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<HistoryModel>> getHistory() async {
    final user = supabase.auth.currentUser;

    // Jika belum login, tidak ada history yang perlu diambil.
    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map<HistoryModel>(
            (e) => HistoryModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e) {
      // Biarkan error diteruskan ke ViewModel
      // agar bisa ditangani oleh UI.
      rethrow;
    }
  }

  Future<void> deleteHistory(String id) async {
    await supabase
        .from('history')
        .delete()
        .eq('id', id);
  }
}