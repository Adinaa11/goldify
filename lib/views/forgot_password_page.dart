import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final String email =
        _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }

    final bool emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValid) {
      _showMessage('Format email tidak valid.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'goldify://auth-callback',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        borderSide: BorderSide(
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 190,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
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
                      const Text(
                        'Lupa Kata Sandi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _emailSent
                            ? 'Link untuk mengatur ulang kata sandi telah dikirim ke email Anda.'
                            : 'Masukkan email yang terdaftar untuk menerima link reset kata sandi.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.done,
                        enabled:
                            !_isLoading && !_emailSent,
                        onSubmitted: (_) {
                          if (!_isLoading &&
                              !_emailSent) {
                            _sendResetLink();
                          }
                        },
                        decoration: _inputDecoration(
                          label: 'Email',
                          hint:
                              'Masukkan alamat email',
                          icon:
                              Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _emailSent
                              ? () {
                                  Navigator.pop(
                                    context,
                                  );
                                }
                              : (_isLoading
                                  ? null
                                  : _sendResetLink),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFF7931E),
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFF7931E)
                                    .withOpacity(0.6),
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
                          child: _emailSent
                              ? const Text(
                                  'Kembali ke Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                )
                              : (_isLoading
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
                                      'Kirim Link Reset',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    )),
                        ),
                      ),

                      if (_emailSent) ...[
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(0xFFEAF7EE),
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFB9E2C2,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .mark_email_read_outlined,
                                size: 38,
                                color: Color(
                                  0xFF2E9B4B,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Email reset telah dikirim',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Color(
                                    0xFF2E9B4B,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                emailText,
                                textAlign:
                                    TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(
                                    0xFF4B5563,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Silakan buka email Anda dan klik link untuk membuat kata sandi baru.',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      if (!_emailSent)
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                          child: const Text(
                            'Kembali ke Login',
                            style: TextStyle(
                              color:
                                  Color(0xFFF7931E),
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/bawah.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get emailText {
    return _emailController.text.trim();
  }
}