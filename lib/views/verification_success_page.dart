import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'login_page.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState
    extends State<VerificationSuccessPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
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
                        const SizedBox(height: 70),

                        // ICON BERHASIL
                        Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3E6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Color(0xFFF7931E),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // JUDUL
                        const Text(
                          'Verifikasi Berhasil!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // DESKRIPSI
                        const Text(
                          'Akun Anda berhasil diverifikasi. '
                          'Silakan masuk menggunakan akun yang telah didaftarkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF4B5563),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // TOMBOL LOGIN
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                               Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFF7931E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Masuk ke Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 250),
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

            // CONFETTI DI SEKITAR ICON CENTANG
            Positioned(
              top: 45,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 25,
                gravity: 0.2,
                emissionFrequency: 0.05,
                maxBlastForce: 20,
                minBlastForce: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}