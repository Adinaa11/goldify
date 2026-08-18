import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();

    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const HomePage();
          },
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: FadeTransition(
          opacity: _fadeAnimation,
            child: Column(
              children: [
                // GAMBAR ATAS
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/atas.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),

                // AREA TENGAH
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 180,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // GOLDIFY
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'GOLD',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'IFY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 3),

                        // NAMA PERUSAHAAN
                        const Text(
                          'By PT Equityworld Futures',
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // GAMBAR BAWAH
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/bawah.png',
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