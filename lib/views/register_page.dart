import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../viewmodels/register_viewmodel.dart';
import 'verification_success_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf besar.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 huruf kecil.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus memiliki minimal 1 angka.';
    }
    return null;
  }

  Future<void> _register() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final nama = _namaController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (nama.isEmpty) {
      _showMessage('Nama lengkap wajib diisi.');
      return;
    }

    if (whatsapp.isEmpty) {
      _showMessage('Nomor WhatsApp wajib diisi.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }

    final emailValid =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!emailValid) {
      _showMessage('Format email tidak valid.');
      return;
    }

    final passwordError = _validatePassword(password);

    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Konfirmasi password tidak sama dengan password.');
      return;
    }

    if (!_agreeTerms) {
      _showMessage(
        'Silakan setujui syarat dan ketentuan terlebih dahulu.',
      );
      return;
    }

    final error = _viewModel.validateRegister(
      nama: nama,
      whatsapp: whatsapp,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      agreeTerms: _agreeTerms,
    );

    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': nama,
          'whatsapp': whatsapp,
        },
      );

      if (response.user == null) {
        throw const AuthException(
          'Pendaftaran gagal. Silakan coba lagi.',
        );
      }

      if (response.session != null) {
        await _supabase.auth.signOut();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificationSuccessPage(),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String message = e.message;

      if (message.toLowerCase().contains('already registered') ||
          message.toLowerCase().contains('already exists') ||
          message.toLowerCase().contains('already been registered')) {
        message = 'Email tersebut sudah terdaftar. Silakan login.';
      } else if (message.toLowerCase().contains('invalid')) {
        message = 'Data pendaftaran tidak valid.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan saat mendaftar. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showTermsDialog() {
    bool readAndUnderstand = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              title: const Center(
                child: Text(
                  'Syarat dan Ketentuan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang di Goldify. Dengan menggunakan '
                        'aplikasi Goldify, Anda menyetujui dan bersedia '
                        'mematuhi Syarat dan Ketentuan berikut.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '1. Tentang Goldify',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Goldify merupakan aplikasi yang menyediakan fitur '
                        'kalkulator dan informasi terkait perhitungan emas '
                        'serta analisis pasar, termasuk kalkulator Emas Fisik, '
                        'Pivot Point, dan Hangseng.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '2. Penggunaan Aplikasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pengguna dapat menggunakan fitur Goldify untuk '
                        'membantu melakukan perhitungan berdasarkan data '
                        'yang dimasukkan ke dalam aplikasi.\n\n'
                        'Pengguna bertanggung jawab atas data yang dimasukkan '
                        'dan penggunaan hasil perhitungan yang diberikan '
                        'oleh aplikasi.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '3. Hasil Perhitungan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hasil yang ditampilkan oleh Goldify merupakan '
                        'informasi dan alat bantu perhitungan, bukan '
                        'merupakan rekomendasi atau jaminan keuntungan '
                        'dalam melakukan investasi maupun perdagangan.\n\n'
                        'Keputusan untuk melakukan transaksi atau investasi '
                        'sepenuhnya menjadi tanggung jawab pengguna.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '4. Data Pasar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Data pasar yang digunakan oleh aplikasi dapat '
                        'berasal dari sumber data eksternal. Goldify tidak '
                        'menjamin bahwa data tersebut selalu tersedia, '
                        'lengkap, akurat, atau diperbarui secara real-time.\n\n'
                        'Pengguna disarankan untuk melakukan verifikasi '
                        'terhadap data sebelum menggunakannya sebagai dasar '
                        'pengambilan keputusan.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '5. Akun Pengguna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pengguna bertanggung jawab untuk menjaga keamanan '
                        'informasi akun, termasuk email, kata sandi, dan kode '
                        'verifikasi yang digunakan untuk mengakses aplikasi.\n\n'
                        'Pengguna tidak diperkenankan menggunakan akun untuk '
                        'aktivitas yang melanggar hukum atau merugikan pihak lain.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '6. Hak dan Pembaruan Aplikasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Goldify dapat melakukan perubahan, pembaruan, '
                        'penambahan, atau penghentian fitur tertentu untuk '
                        'meningkatkan kualitas aplikasi.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        '7. Persetujuan Pengguna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Dengan mencentang “Saya menyetujui Syarat dan '
                        'Ketentuan Penggunaan Aplikasi”, pengguna menyatakan '
                        'telah membaca, memahami, dan menyetujui seluruh '
                        'ketentuan yang berlaku dalam penggunaan Goldify.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: readAndUnderstand,
                      activeColor: const Color(0xFFF7931E),
                      onChanged: (value) {
                        setDialogState(() {
                          readAndUnderstand = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Saya telah membaca dan mengerti Syarat dan Ketentuan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: readAndUnderstand
                        ? () {
                            Navigator.pop(dialogContext);

                            if (mounted) {
                              setState(() {
                                _agreeTerms = true;
                              });
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7931E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFF7931E).withValues(alpha: 0.35),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SETUJU & LANJUTKAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Center(
                      child: Text(
                        'Daftar Akun',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Silakan daftar terlebih dahulu untuk dapat '
                        'mengakses aplikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _namaController,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nomor WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Nomor WhatsApp',
                        hint: 'Contoh: 081234567890',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'Masukkan alamat email',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'Min. 8 karakter, huruf besar, kecil & angka',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Konfirmasi Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      enabled: !_isLoading,
                      decoration: _inputDecoration(
                        label: 'Konfirmasi Password',
                        hint: 'Masukkan kembali password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 4,
                        top: 2,
                      ),
                      child: Text(
                        'Password minimal 8 karakter dan harus '
                        'mengandung huruf besar, huruf kecil, serta angka.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          activeColor: const Color(0xFFF7931E),
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _agreeTerms = value ?? false;
                                  });
                                },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Saya menyetujui ',
                                  ),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: const TextStyle(
                                      color: Color(0xFFF7931E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _isLoading
                                          ? null
                                          : _showTermsDialog,
                                  ),
                                  const TextSpan(
                                    text: ' Penggunaan Aplikasi.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7931E),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFFF7931E).withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah memiliki akun? ',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFF7931E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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