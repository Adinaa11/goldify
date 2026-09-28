import 'package:supabase_flutter/supabase_flutter.dart';

class NewPasswordViewModel {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password minimal 8 karakter.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf besar.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf kecil.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 angka.';
    }

    return null;
  }

  Future<String?> updatePassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return 'Password wajib diisi.';
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return passwordError;
    }

    if (password != confirmPassword) {
      return 'Konfirmasi password tidak sesuai.';
    }

    final user = _supabase.auth.currentUser;

    if (user == null) {
      return 'Sesi reset password tidak ditemukan. Silakan lakukan proses lupa password kembali.';
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );

      await _supabase.auth.signOut();

      return null; // sukses
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan saat memperbarui password. Silakan coba lagi.';
    }
  }
}