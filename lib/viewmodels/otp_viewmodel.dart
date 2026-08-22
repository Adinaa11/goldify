import '../models/otp_model.dart';

class OtpViewModel {
  bool isLoading = false;
  
  String? _generatedOtp;

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

  // MEMBUAT OTP
  // Untuk testing sementara, OTP selalu 123456.
  String generateOtp() {
    _generatedOtp = '123456';

    return _generatedOtp!;
  }

  // VERIFIKASI OTP
  bool verifyOtp(String otp) {
    if (_generatedOtp == null) {
      return false;
    }

    return otp == _generatedOtp;
  }

  // HAPUS OTP
  void clearOtp() {
    _generatedOtp = null;
  }
}