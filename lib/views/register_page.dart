import 'package:flutter/material.dart';
import '../viewmodels/register_viewmodel.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _whatsappController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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

  void _register() {
    final error = _viewModel.validateRegister(
      nama: _namaController.text,
      whatsapp: _whatsappController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      agreeTerms: _agreeTerms,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    final registerData = _viewModel.createRegisterData(
      nama: _namaController.text,
      whatsapp: _whatsappController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    debugPrint('Nama: ${registerData.nama}');
    debugPrint('WhatsApp: ${registerData.whatsapp}');
    debugPrint('Email: ${registerData.email}');

   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OtpPage(
        whatsapp: _whatsappController.text,
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 10),

              // INFORMASI
              Center(
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

              const SizedBox(height: 30),

              // NAMA
              const Text(
                'Nama Lengkap',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _namaController,
                decoration: _inputDecoration(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 18),

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
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  label: 'Email',
                  hint: 'Masukkan alamat email',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 18),

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
                  hint: 'Masukkan password',
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

              const SizedBox(height: 18),

              // KONFIRMASI PASSWORD
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

              const SizedBox(height: 15),

              // TERMS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: const Color(0xFFF7931E),
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = value ?? false;
                      });
                    },
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
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

              const SizedBox(height: 15),

              // BUTTON DAFTAR
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7931E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LOGIN
              Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Sudah memiliki akun? ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color(0xFFF7931E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 3),
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