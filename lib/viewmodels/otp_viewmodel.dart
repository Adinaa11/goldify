import '../models/otp_model.dart';

class OtpViewModel {
  bool isLoading = false;

  String? validateOtp({
    required String otp,
  }) {
    if (otp.isEmpty) {
      return 'Kode OTP wajib diisi';
    }

    if (otp.length != 6) {
      return 'Kode OTP harus terdiri dari 6 angka';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return 'Kode OTP hanya boleh berisi angka';
    }

    return null;
  }

  OtpModel createOtpData({
    required String whatsapp,
    required String otp,
  }) {
    return OtpModel(
      whatsapp: whatsapp,
      otp: otp,
    );
  }

  // Sementara untuk pengecekan UI.
  // Nanti akan diganti dengan proses verifikasi
  // melalui backend.
  bool verifyOtp(String otp) {
    return otp.length == 6;
  }
}