import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

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
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final String email =
        _loginController.text.trim().toLowerCase();
    final String password =
        _passwordController.text;

    // CEK INPUT KOSONG
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email dan password wajib diisi.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // CEK FORMAT EMAIL
    final bool emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValid) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format email tidak valid.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // LOGIN KE SUPABASE
      final response =
          await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final user = response.user;

      if (user == null) {
        throw const AuthException(
          'Login gagal. Silakan coba lagi.',
        );
      }

      // CEK EMAIL SUDAH DIVERIFIKASI
      if (user.emailConfirmedAt == null) {
        await _supabase.auth.signOut();

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email Anda belum diverifikasi. '
              'Silakan buka email konfirmasi terlebih dahulu.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // LOGIN BERHASIL
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = e.message;

      final String lowerMessage =
          message.toLowerCase();

      if (lowerMessage.contains('invalid login credentials') ||
          lowerMessage.contains('invalid credentials')) {
        message =
            'Email atau password salah.';
      } else if (lowerMessage.contains('email not confirmed')) {
        message =
            'Email Anda belum diverifikasi. '
            'Silakan cek email konfirmasi terlebih dahulu.';
      } else if (lowerMessage.contains('email')) {
        message =
            'Email atau password tidak sesuai.';
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terjadi kesalahan saat login. Silakan coba lagi.',
          ),
          behavior: SnackBarBehavior.floating,
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

                    // EMAIL
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Email',
                        hint:
                            'Masukkan alamat email',
                        icon:
                            Icons.email_outlined,
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
                      enabled: !_isLoading,
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
                        onTap: _isLoading
                            ? null
                            : () {
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
                                onTap: _isLoading
                                    ? null
                                    : () {
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