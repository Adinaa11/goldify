import 'dart:async';

import 'package:flutter/material.dart';
import '../viewmodels/otp_viewmodel.dart';
import 'verification_success_page.dart';
import 'new_password_page.dart';

enum OtpPurpose {
  registration,
  resetPassword,
}

class OtpPage extends StatefulWidget {
  final String whatsapp;
  final OtpPurpose purpose;

  const OtpPage({
    super.key,
    required this.whatsapp,
    required this.purpose,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final OtpViewModel _viewModel = OtpViewModel();
  Timer? _timer;
  int _remainingSeconds = 60;

  void _startTimer() {
  _timer?.cancel();

  _remainingSeconds = 60;

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    },
  );
}

  final List<TextEditingController> _otpControllers =
      List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
      List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  String get _otp {
    return _otpControllers
        .map((controller) => controller.text)
        .join();
  }

  void _verifyOtp() {
    final error = _viewModel.validateOtp(
      otp: _otp,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    final otpData = _viewModel.createOtpData(
      whatsapp: widget.whatsapp,
      otp: _otp,
    );

    debugPrint('WhatsApp: ${otpData.whatsapp}');
    debugPrint('OTP: ${otpData.otp}');

    if (_viewModel.verifyOtp(_otp)) {
      if (widget.purpose == OtpPurpose.registration) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const VerificationSuccessPage(),
          ),
        );
      } else if (widget.purpose == OtpPurpose.resetPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const NewPasswordPage(),
          ),
        );
      }
    }
  }

  void _resendOtp() {
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kode OTP akan dikirim ulang.',
        ),
      ),
    );
  }

  InputDecoration _otpDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade500,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade500,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFF7931E),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    // LOGO
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // JUDUL
                    const Text(
                      'Verifikasi OTP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // INFORMASI
                    const Text(
                      'Masukkan kode OTP yang telah dikirim '
                      'ke nomor WhatsApp Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color.fromARGB(255, 52, 54, 57),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // NOMOR WHATSAPP
                    Text(
                      widget.whatsapp,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7931E),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // OTP INPUT
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller:
                                  _otpControllers[index],
                              focusNode:
                                  _focusNodes[index],
                              keyboardType:
                                  TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration:
                                  _otpDecoration(),
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    index < 5) {
                                  _focusNodes[index + 1]
                                      .requestFocus();
                                }

                                if (value.isEmpty &&
                                    index > 0) {
                                  _focusNodes[index - 1]
                                      .requestFocus();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL VERIFIKASI
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _verifyOtp,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF7931E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_remainingSeconds > 0)
                      Text(
                        'Kode OTP dapat dikirim ulang dalam '
                        '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _resendOtp,
                        child: const Text(
                          'Kirim ulang OTP',
                          style: TextStyle(
                            color: Color(0xFFF7931E),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 200),
                  ],
                ),
              ),

              // GAMBAR BAWAH
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/bawah.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}