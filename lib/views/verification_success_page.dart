import 'dart:math';

import 'package:flutter/material.dart';

import 'login_page.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState
    extends State<VerificationSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _confettiController.repeat();
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
      body: Stack(
        children: [
         
          SafeArea(
            child: Column(
              children: [
                Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -65),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.contain,
                            ),
                          ),
                    
                          const SizedBox(height: 10),

                          Container(
                            width: 82,
                            height: 82,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF7EE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 48,
                              color: Color(0xFF2E9B4B),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Pendaftaran Berhasil!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Akun Goldify kamu berhasil dibuat.\n'
                            'Silakan login untuk mulai menggunakan aplikasi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginPage(),
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
                                'Login Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/bawah.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({
    required this.progress,
  });

  static final Random _random = Random(42);

  static final List<_ConfettiParticle> _particles =
      List.generate(55, (index) {
    final angle = _random.nextDouble() * pi * 2;

    return _ConfettiParticle(
      angle: angle,
      distance: 30 + _random.nextDouble() * 250,
      delay: _random.nextDouble() * 0.25,
      speed: 0.7 + _random.nextDouble() * 0.5,
      size: 4 + _random.nextDouble() * 5,
      rotation: _random.nextDouble() * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 5,
      type: _random.nextInt(3),
      colorIndex: _random.nextInt(5),
    );
  });

  static const List<Color> _colors = [
    Color(0xFFF7931E),
    Color(0xFFFFC107),
    Color(0xFF2E9B4B),
    Color(0xFFFF6B6B),
    Color(0xFF5B8DEF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Titik awal confetti = sekitar tanda centang
    final center = Offset(
      size.width * 0.5,
      size.height * 0.47,
    );

    for (final particle in _particles) {
      final rawProgress =
          (progress - particle.delay) * particle.speed;

      if (rawProgress <= 0) continue;

      final animation = rawProgress.clamp(0.0, 1.0);

      final distance =
          particle.distance * Curves.easeOut.transform(animation);

      final gravity =
          70 * animation * animation;

      final x =
          center.dx +
          cos(particle.angle) * distance;

      final y =
          center.dy +
          sin(particle.angle) * distance +
          gravity;

      final rotation =
          particle.rotation +
          animation * particle.rotationSpeed;

      final paint = Paint()
        ..color = _colors[particle.colorIndex]
        ..style = PaintingStyle.fill;

      canvas.save();

      canvas.translate(x, y);
      canvas.rotate(rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 1.7,
      );

      if (particle.type == 0) {
        canvas.drawRect(rect, paint);
      } else if (particle.type == 1) {
        canvas.drawCircle(
          Offset.zero,
          particle.size / 2,
          paint,
        );
      } else {
        final path = Path()
          ..moveTo(0, -particle.size)
          ..lineTo(particle.size * 0.7, 0)
          ..lineTo(0, particle.size)
          ..lineTo(-particle.size * 0.7, 0)
          ..close();

        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConfettiParticle {
  final double angle;
  final double distance;
  final double delay;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final int type;
  final int colorIndex;

  _ConfettiParticle({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.type,
    required this.colorIndex,
  });
}