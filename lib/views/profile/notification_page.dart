import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  bool systemNotif = true;
  bool emailNotif = true;
  bool promoNotif = false;
  bool sound = true;
  bool vibration = true;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFF7931E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: const [
                  Icon(Icons.notifications_active,
                      size: 40, color: Color(0xFFF7931E)),
                  SizedBox(height: 10),
                  Text(
                    "Pengaturan Notifikasi",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Atur notifikasi sesuai kebutuhan Anda",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// CARD NOTIFIKASI
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _switchItem(
                    "Notifikasi Sistem",
                    systemNotif,
                    (val) {
                      setState(() => systemNotif = val);
                      _showSnack("Notifikasi Sistem ${val ? 'aktif' : 'mati'}");
                    },
                  ),
                  _divider(),

                  _switchItem(
                    "Notifikasi Email",
                    emailNotif,
                    (val) {
                      setState(() => emailNotif = val);
                      _showSnack("Notifikasi Email ${val ? 'aktif' : 'mati'}");
                    },
                  ),
                  _divider(),

                  _switchItem(
                    "Notifikasi Promo",
                    promoNotif,
                    (val) {
                      setState(() => promoNotif = val);
                      _showSnack("Notifikasi Promo ${val ? 'aktif' : 'mati'}");
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// CARD EFEK
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _switchItem(
                    "Suara",
                    sound,
                    (val) {
                      setState(() => sound = val);
                      _showSnack("Suara ${val ? 'aktif' : 'mati'}");
                    },
                  ),
                  _divider(),

                  _switchItem(
                    "Getaran",
                    vibration,
                    (val) {
                      setState(() => vibration = val);
                      _showSnack("Getaran ${val ? 'aktif' : 'mati'}");
                    },
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

  /// SWITCH ITEM (CLEAN & CONSISTENT)
  Widget _switchItem(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFFF7931E).withOpacity(0.5),
          activeColor: const Color(0xFFF7931E),
        )
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1),
      );
}