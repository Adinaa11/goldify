import 'package:flutter/material.dart';

class AppVersionPage extends StatelessWidget {
  const AppVersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: const Text(
          "Versi Aplikasi",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 40),

          // ================= LOGO =================
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png', // pastikan ada
                  width: 80,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Goldify",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Versi 2.1.4",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= CARD =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.system_update),
                  title: Text("Versi Saat Ini"),
                  trailing: Text("2.1.4"),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.new_releases),
                  title: Text("Update"),
                  subtitle: Text("Aplikasi sudah versi terbaru"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}