import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/register_viewmodel.dart';
import 'otp_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _whatsappController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _namaController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // VALIDASI PASSWORD
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

  // SIMPAN DATA REGISTRASI
  Future<void> _saveAccountData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'registered_name',
      _namaController.text.trim(),
    );

    await prefs.setString(
      'registered_whatsapp',
      _whatsappController.text.trim(),
    );

    await prefs.setString(
      'registered_email',
      _emailController.text.trim(),
    );

    await prefs.setString(
      'registered_password',
      _passwordController.text,
    );
  }

  // REGISTER
  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final nama = _namaController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // CEK DATA WAJIB
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

    // CEK FORMAT EMAIL
    final emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValid) {
      _showMessage('Format email tidak valid.');
      return;
    }

    // CEK PASSWORD
    final passwordError = _validatePassword(password);

    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    // CEK KONFIRMASI PASSWORD
    if (password != confirmPassword) {
      _showMessage(
        'Konfirmasi password tidak sama dengan password.',
      );
      return;
    }

    // CEK SETUJU SYARAT DAN KETENTUAN
    if (!_agreeTerms) {
      _showMessage(
        'Silakan setujui syarat dan ketentuan terlebih dahulu.',
      );
      return;
    }

    // VALIDASI VIEWMODEL
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

    // BUAT DATA REGISTER
    final registerData = _viewModel.createRegisterData(
      nama: nama,
      whatsapp: whatsapp,
      email: email,
      password: password,
    );

    debugPrint('Nama: ${registerData.nama}');
    debugPrint('WhatsApp: ${registerData.whatsapp}');
    debugPrint('Email: ${registerData.email}');

    await _saveAccountData();

    if (!mounted) return;

    // LANJUT KE HALAMAN OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpPage(
          whatsapp: whatsapp,
          purpose: OtpPurpose.registration,
        ),
      ),
    );
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

                    // INFORMASI
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

                    // NAMA LENGKAP
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _namaController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // WHATSAPP
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
                      decoration: _inputDecoration(
                        label: 'Nomor WhatsApp',
                        hint: 'Contoh: 081234567890',
                        icon: Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // EMAIL
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'Masukkan alamat email',
                        icon: Icons.email_outlined,
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
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'Min. 8 karakter, huruf besar, kecil & angka',
                        icon: Icons.lock_outline,

                        suffixIcon: IconButton(
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

                    // KONFIRMASI PASSWORD
                    const Text(
                      'Konfirmasi Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,

                      decoration: _inputDecoration(
                        label: 'Konfirmasi Password',
                        hint: 'Masukkan kembali password',
                        icon: Icons.lock_outline,

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
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

                    // INFORMASI PASSWORD
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          activeColor:
                              const Color(0xFFF7931E),

                          onChanged: (value) {
                            setState(() {
                              _agreeTerms =
                                  value ?? false;
                            });
                          },
                        ),

                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 12,
                            ),

                            child: Text(
                              'Saya menyetujui syarat dan ketentuan '
                              'penggunaan aplikasi.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // BTN DAFTAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton(
                        onPressed: _register,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF7931E),

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //LOGIN
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text:
                              'Sudah memiliki akun? ',

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),

                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
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
                                    color:
                                        Color(0xFFF7931E),
                                    fontWeight:
                                        FontWeight.bold,
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