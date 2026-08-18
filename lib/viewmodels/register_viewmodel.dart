import '../models/register_model.dart';

class RegisterViewModel {
  bool isLoading = false;

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

    if (whatsapp.length < 10) {
      return 'Nomor WhatsApp tidak valid';
    }

    if (email.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    if (!email.contains('@')) {
      return 'Email tidak valid';
    }

    if (password.isEmpty) {
      return 'Password wajib diisi';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter';
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
      nama: nama,
      whatsapp: whatsapp,
      email: email,
      password: password,
    );
  }
}