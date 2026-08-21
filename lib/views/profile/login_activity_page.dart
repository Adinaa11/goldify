import 'package:flutter/material.dart';

class LoginActivityPage extends StatelessWidget {
  const LoginActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: const Text(
          "Aktivitas Login",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 16),

            // ================= PERANGKAT SAAT INI =================
            _sectionTitle("PERANGKAT SAAT INI"),

            _currentDevice(),

            const SizedBox(height: 16),

            // ================= RIWAYAT =================
            _sectionTitle("PERANGKAT LAIN"),

            _deviceItem(
              context,
              icon: Icons.laptop,
              device: "Windows - Chrome",
              location: "Surabaya, Indonesia",
              time: "Kemarin, 21:00",
            ),

            _deviceItem(
              context,
              icon: Icons.phone_android,
              device: "Android - Xiaomi",
              location: "Malang, Indonesia",
              time: "2 hari lalu, 14:10",
            ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Keluar dari Semua Perangkat Lain",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CURRENT DEVICE =================
  Widget _currentDevice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5D2A9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_android, color: Color(0xFFF7931E)),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Android - Samsung A35",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Surabaya, Indonesia",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 2),
                Text(
                  "Aktif sekarang • Login sejak hari ini, 10:30",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  // ================= DEVICE ITEM =================
  Widget _deviceItem(
    BuildContext context, {
    required IconData icon,
    required String device,
    required String location,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFF7931E)),
        title: Text(device),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lokasi: $location"),
            Text("Login terakhir: $time"),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "logout",
              child: Text("Keluar dari perangkat ini"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= POPUP LOGOUT =================
  void _showLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.logout, color: Colors.red, size: 40),

                const SizedBox(height: 12),

                const Text(
                  "Keluar dari Semua Perangkat?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Anda akan keluar dari semua perangkat lain kecuali perangkat ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Keluar"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}