import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Keamanan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER (CONSISTENT STYLE)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: const [
                  Icon(Icons.security, size: 40, color: Color(0xFFF7931E)),
                  SizedBox(height: 10),
                  Text(
                    "Keamanan Akun",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Kelola password & aktivitas login",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// CARD MENU (SAMA SEPERTI PROFILE)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _item(
                    context,
                    "Ubah Kata Sandi",
                    "Perbarui password akun",
                    Icons.lock_outline,
                    const ChangePasswordPage(),
                  ),
                  _divider(),
                  _item(
                    context,
                    "Aktivitas Login",
                    "Kelola perangkat login",
                    Icons.devices,
                    const LoginActivityPage(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFO CARD (CONSISTENT)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFF7931E)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Gunakan password kuat dan jangan bagikan akun Anda.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String title, String subtitle,
      IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => page));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF7931E)),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool hideOld = true;
  bool hideNew = true;
  bool hideConfirm = true;

  void _save() {
    if (oldPass.text.isEmpty ||
        newPass.text.isEmpty ||
        confirmPass.text.isEmpty) {
      _msg("Semua field wajib diisi");
      return;
    }

    if (newPass.text != confirmPass.text) {
      _msg("Password tidak sama");
      return;
    }

    _msg("Link konfirmasi dikirim ke email");
    Navigator.pop(context);
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Ubah Password"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _field("Password Lama", oldPass, hideOld,
                () => setState(() => hideOld = !hideOld)),
            const SizedBox(height: 12),

            _field("Password Baru", newPass, hideNew,
                () => setState(() => hideNew = !hideNew)),
            const SizedBox(height: 12),

            _field("Konfirmasi Password", confirmPass, hideConfirm,
                () => setState(() => hideConfirm = !hideConfirm)),

            const SizedBox(height: 24),

            /// BUTTON (SAMA STYLE PROFILE)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7931E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(
      String hint, TextEditingController c, bool hide, VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: hide,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class LoginActivityPage extends StatefulWidget {
  const LoginActivityPage({super.key});

  @override
  State<LoginActivityPage> createState() =>
      _LoginActivityPageState();
}

class _LoginActivityPageState extends State<LoginActivityPage> {
  List<Map<String, String>> devices = [
    {
      "device": "Samsung A35",
      "location": "Surabaya",
      "time": "Aktif sekarang"
    },
    {
      "device": "Chrome Windows",
      "location": "Malang",
      "time": "2 jam lalu"
    },
  ];

  void _logoutDevice(int index) {
    final deviceName = devices[index]["device"];

    setState(() {
      devices.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout dari $deviceName berhasil")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Aktivitas Login"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final d = devices[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices,
                    color: Color(0xFFF7931E)),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d["device"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text("${d["location"]} • ${d["time"]}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () => _logoutDevice(index),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}