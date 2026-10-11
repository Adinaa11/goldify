import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordViewModel {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> sendResetLink(String email) async {
    final String cleanEmail = email.trim().toLowerCase();

    // VALIDASI
    if (cleanEmail.isEmpty) {
      return 'Email wajib diisi.';
    }

    final bool emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(cleanEmail);

    if (!emailValid) {
      return 'Format email tidak valid.';
    }

    // LOADING + API CALL
    try {
      await _supabase.auth.resetPasswordForEmail(
        cleanEmail,
        redirectTo: 'goldify://reset-password',
      );

      return null; // sukses
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}