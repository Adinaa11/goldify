import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository repository;

  LoginViewModel(this.repository);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _errorMessage = null;

    _isLoading = true;
    notifyListeners();

    try {
      final User? user = await repository.login(
        email: email,
        password: password,
      );

      if (user == null) {
        _errorMessage =
            'Login gagal. Silakan coba lagi.';
        return false;
      }

      return true;
    } on AuthException catch (e) {
      final String lowerMessage =
          e.message.toLowerCase();

      if (lowerMessage.contains(
            'invalid login credentials',
          ) ||
          lowerMessage.contains(
            'invalid credentials',
          )) {
        _errorMessage =
            'Email atau password salah.';
      } else {
        _errorMessage =
            'Email atau password tidak sesuai.';
      }

      return false;
    } catch (e) {
      _errorMessage =
          'Terjadi kesalahan saat login. Silakan coba lagi.';

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