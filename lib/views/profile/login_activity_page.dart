import 'package:flutter/material.dart';

class LoginActivityPage extends StatefulWidget {
  const LoginActivityPage({super.key});

  @override
  State<LoginActivityPage> createState() => _LoginActivityPageState();
}

class _LoginActivityPageState extends State<LoginActivityPage> {

  // ✅ DATA DEVICE
  List<Map<String, dynamic>> devices = [
    {
      "icon": Icons.laptop,
      "device": "Windows - Chrome",
      "location": "Surabaya, Indonesia",
      "time": "Kemarin, 21:00",
    },
    {
      "icon": Icons.phone_android,
      "device": "Android - Xiaomi",
      "location": "Malang, Indonesia",
      "time": "2 hari lalu, 14:10",
    },
  ];

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

            // ================= PERANGKAT LAIN =================
            _sectionTitle("PERANGKAT LAIN"),

            // ✅ LOOP DEVICE
            if (devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Tidak ada perangkat lain",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...devices.map((device) => _deviceItem(context, device)).toList(),

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
        children: const [
          Icon(Icons.phone_android, color: Color(0xFFF7931E)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  "Aktif sekarang",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  // ================= DEVICE ITEM =================
  Widget _deviceItem(BuildContext context, Map device) {
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
        leading: Icon(device["icon"], color: const Color(0xFFF7931E)),
        title: Text(device["device"]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lokasi: ${device["location"]}"),
            Text("Login terakhir: ${device["time"]}"),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "logout") {
              setState(() {
                devices.remove(device); // ✅ hapus device
              });

              _showSnack("Berhasil keluar dari perangkat");
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "logout",
              child: Text("Keluar dari perangkat ini"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= POPUP LOGOUT ALL =================
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

                          setState(() {
                            devices.clear(); // ✅ hapus semua device
                          });

                          _showSnack("Berhasil keluar dari semua perangkat");
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

  // ================= SNACKBAR =================
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}