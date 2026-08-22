import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String login = _loginController.text.trim();
    final String password = _passwordController.text;

    // CEK INPUT KOSONG
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email/WhatsApp dan password wajib diisi.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      // AMBIL DATA YANG DISIMPAN SAAT REGISTER
      final String? registeredName =
          prefs.getString('registered_name');

      final String? registeredEmail =
          prefs.getString('registered_email');

      final String? registeredWhatsapp =
          prefs.getString('registered_whatsapp');

      final String? registeredPassword =
          prefs.getString('registered_password');

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      // CEK APAKAH DATA AKUN ADA
      if (registeredName == null ||
          registeredEmail == null ||
          registeredWhatsapp == null ||
          registeredPassword == null) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akun belum terdaftar. Silakan daftar terlebih dahulu.',
            ),
          ),
        );

        return;
      }

      // CEK EMAIL ATAU WHATSAPP
      final bool loginDenganEmail =
          login.toLowerCase() ==
          registeredEmail.trim().toLowerCase();

      final bool loginDenganWhatsapp =
          login ==
          registeredWhatsapp.trim();

      if (!loginDenganEmail && !loginDenganWhatsapp) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email/WhatsApp tidak sesuai dengan akun yang terdaftar.',
            ),
          ),
        );

        return;
      }

      // CEK PASSWORD
      if (password != registeredPassword) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password salah. Silakan masukkan password yang sesuai.',
            ),
          ),
        );

        return;
      }

      // LOGIN BERHASIL
      await prefs.setBool(
        'is_logged_in',
        true,
      );

      // SIMPAN NAMA USER YANG SEDANG LOGIN
      await prefs.setString(
        'logged_in_name',
        registeredName.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // MASUK KE HOME
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terjadi kesalahan. Silakan coba lagi.',
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.grey.shade50,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
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
        bottom: false,

        child: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        'MASUK',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // INFO
                    const Center(
                      child: Text(
                        'Silakan masuk menggunakan akun '
                        'yang telah terdaftar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // EMAIL / WHATSAPP
                    const Text(
                      'Email / WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _loginController,

                      keyboardType:
                          TextInputType.text,

                      textInputAction:
                          TextInputAction.next,

                      decoration: _inputDecoration(
                        label:
                            'Email / Nomor WhatsApp',
                        hint:
                            'Masukkan email atau nomor WhatsApp',
                        icon:
                            Icons.person_outline,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PASSWORD
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          _passwordController,

                      obscureText:
                          _obscurePassword,

                      textInputAction:
                          TextInputAction.done,

                      onSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },

                      decoration: _inputDecoration(
                        label: 'Password',
                        hint:
                            'Masukkan password',
                        icon:
                            Icons.lock_outline,

                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LUPA PASSWORD
                    Align(
                      alignment:
                          Alignment.centerRight,

                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordPage(),
                            ),
                          );
                        },

                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color:
                                Color(0xFFF7931E),
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BTN LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                0xFFF7931E,
                              ),

                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              const Color(
                                0xFFF7931E,
                              ),

                          disabledForegroundColor:
                              Colors.white,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),

                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // REGISTER
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text:
                              'Belum memiliki akun? ',

                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),

                          children: [
                            WidgetSpan(
                              child:
                                  GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const RegisterPage(),
                                    ),
                                  );
                                },

                                child: const Text(
                                  'Daftar',
                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFFF7931E,
                                    ),
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 130),
                  ],
                ),
              ),

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