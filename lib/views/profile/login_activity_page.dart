import 'package:flutter/material.dart';

class LoginActivityPage extends StatefulWidget {
  const LoginActivityPage({super.key});

  @override
  State<LoginActivityPage> createState() => _LoginActivityPageState();
}

class _LoginActivityPageState extends State<LoginActivityPage> {

  // ================= DATA DEVICE =================
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

      body: Column(
        children: [

          const SizedBox(height: 16),

          _sectionTitle("PERANGKAT SAAT INI"),
          _currentDevice(),

          const SizedBox(height: 16),

          _sectionTitle("PERANGKAT LAIN"),

          Expanded(
            child: devices.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada perangkat lain",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView(
                    children: devices
                        .map((device) => _deviceItem(context, device))
                        .toList(),
                  ),
          ),

          // BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
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
        ],
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
            color: Colors.black.withValues(alpha: 0.05),
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

              // ✅ REMOVE DEVICE
              setState(() {
                devices.remove(device);
              });

              // ✅ FEEDBACK
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Keluar dari Semua Perangkat?"),
          content: const Text(
            "Anda akan keluar dari semua perangkat lain kecuali perangkat ini.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  devices.clear();
                });

                _showSnack("Berhasil keluar dari semua perangkat");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  // ================= SNACKBAR =================
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}