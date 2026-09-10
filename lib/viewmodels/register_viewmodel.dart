import '../models/register_model.dart';

class RegisterViewModel {
  bool isLoading = false;

  // VALIDASI PASSWORD
  String? validatePassword(String password) {
    // Minimal 8 karakter
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    // Harus ada huruf besar
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf besar';
    }

    // Harus ada huruf kecil
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf kecil';
    }

    // Harus ada angka
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 angka';
    }

    return null;
  }

  // VALIDASI REGISTER
  String? validateRegister({
    required String nama,
    required String whatsapp,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreeTerms,
  }) {
    // NAMA
    if (nama.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }

    // WHATSAPP
    if (whatsapp.trim().isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }

    final cleanWhatsapp = whatsapp.replaceAll(' ', '');

    if (cleanWhatsapp.length < 10) {
      return 'Nomor WhatsApp tidak valid';
    }

    // Pastikan hanya angka
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanWhatsapp)) {
      return 'Nomor WhatsApp hanya boleh berisi angka';
    }

    // EMAIL
    if (email.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Email tidak valid';
    }

    // PASSWORD
    if (password.isEmpty) {
      return 'Password wajib diisi';
    }

    final passwordError = validatePassword(password);

    if (passwordError != null) {
      return passwordError;
    }

    // KONFIRMASI PASSWORD
    if (confirmPassword.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (password != confirmPassword) {
      return 'Password tidak sama';
    }

    // SYARAT DAN KETENTUAN
    if (!agreeTerms) {
      return 'Silakan menyetujui syarat dan ketentuan';
    }

    return null;
  }

  // CREATE REGISTER DATA
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
}