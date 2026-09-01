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
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: const Text(
          "Notifikasi",
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

            _sectionTitle("NOTIFIKASI UTAMA"),

            // ================= MASTER SWITCH =================
            _switchItem(
              title: "Notifikasi Sistem",
              value: systemNotif,
              onChanged: (val) {
                setState(() {
                  systemNotif = val;

                  // 🔥 kalau dimatiin → semua ikut mati
                  if (!val) {
                    emailNotif = false;
                    promoNotif = false;
                    sound = false;
                    vibration = false;
                  }
                });

                _showSnack("Notifikasi Sistem ${val ? 'aktif' : 'mati'}");
              },
            ),

            _switchItem(
              title: "Notifikasi Email",
              value: emailNotif,
              enabled: systemNotif, // 🔥 disable kalau sistem off
              onChanged: (val) {
                setState(() => emailNotif = val);
                _showSnack("Notifikasi Email ${val ? 'aktif' : 'mati'}");
              },
            ),

            _switchItem(
              title: "Notifikasi Promo",
              value: promoNotif,
              enabled: systemNotif,
              onChanged: (val) {
                setState(() => promoNotif = val);
                _showSnack("Notifikasi Promo ${val ? 'aktif' : 'mati'}");
              },
            ),

            const SizedBox(height: 10),

            _sectionTitle("EFEK NOTIFIKASI"),

            _switchItem(
              title: "Suara",
              value: sound,
              enabled: systemNotif,
              onChanged: (val) {
                setState(() => sound = val);
                _showSnack("Suara ${val ? 'aktif' : 'mati'}");
              },
            ),

            _switchItem(
              title: "Getaran",
              value: vibration,
              enabled: systemNotif,
              onChanged: (val) {
                setState(() => vibration = val);
                _showSnack("Getaran ${val ? 'aktif' : 'mati'}");
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ================= SWITCH ITEM =================
  Widget _switchItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Switch(
            activeColor: const Color(0xFFF7931E),
            value: enabled ? value : false,
            onChanged: enabled ? onChanged : null, // 🔥 disable switch
          ),
        ],
      ),
    );
  }
}