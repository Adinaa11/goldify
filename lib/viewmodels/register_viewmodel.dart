import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/register_model.dart';
import '../repositories/register_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterRepository repository;

  RegisterViewModel(this.repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf besar';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf kecil';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 angka';
    }

    return null;
  }

  String? validateRegister({
    required String nama,
    required String whatsapp,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreeTerms,
  }) {
    if (nama.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }

    if (whatsapp.trim().isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }

    final cleanWhatsapp = whatsapp.replaceAll(' ', '');

    if (cleanWhatsapp.length < 10) {
      return 'Nomor WhatsApp tidak valid';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanWhatsapp)) {
      return 'Nomor WhatsApp hanya boleh berisi angka';
    }

    if (email.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Email tidak valid';
    }

    if (password.isEmpty) {
      return 'Password wajib diisi';
    }

    final passwordError = validatePassword(password);

    if (passwordError != null) {
      return passwordError;
    }

    if (confirmPassword.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (password != confirmPassword) {
      return 'Password tidak sama';
    }

    if (!agreeTerms) {
      return 'Silakan menyetujui syarat dan ketentuan';
    }

    return null;
  }

  RegisterModel createRegisterData({
    required String nama,
    required String whatsapp,
    required String email,
    required String password,
  }) {
    return RegisterModel(
      nama: nama.trim(),
      whatsapp: whatsapp.trim(),
      email: email.trim(),
      password: password,
    );
  }

  Future<bool> register({
    required String nama,
    required String whatsapp,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final data = createRegisterData(
        nama: nama,
        whatsapp: whatsapp,
        email: email,
        password: password,
      );

      await repository.register(data);

      return true;
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();

      if (message.contains('already registered') ||
          message.contains('already exists') ||
          message.contains('already been registered')) {
        _errorMessage =
            'Email tersebut sudah terdaftar. Silakan login.';
      } else if (message.contains('invalid')) {
        _errorMessage = 'Data pendaftaran tidak valid.';
      } else {
        _errorMessage =
            'Data pendaftaran tidak valid.';
      }

      return false;
    } catch (e) {
      debugPrint('Register error: $e');

      _errorMessage =
          'Terjadi kesalahan saat mendaftar. Silakan coba lagi.';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}