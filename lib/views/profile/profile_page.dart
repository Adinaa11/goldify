import 'package:flutter/material.dart';

import 'personal_info_page.dart';
import 'security_page.dart';
import 'notification_page.dart';
import 'app_version_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';
import '../splash_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "John Doe",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "johndoe@email.com",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ================= ACCOUNT =================
            _sectionTitle("AKUN"),

            _menuItem(
              context,
              Icons.person,
              "Informasi Pribadi",
              const PersonalInfoPage(),
            ),
            _menuItem(
              context,
              Icons.shield_outlined,
              "Keamanan",
              const SecurityPage(),
            ),
            _menuItem(
              context,
              Icons.notifications_none,
              "Notifikasi",
              const NotificationPage(),
            ),

            const SizedBox(height: 10),

            /// ================= INFO APP =================
            _sectionTitle("INFO APLIKASI"),

            _menuItem(
              context,
              Icons.info_outline,
              "Versi Aplikasi",
              const AppVersionPage(),
              trailing: "v2.1.4",
            ),
            _menuItem(
              context,
              Icons.description_outlined,
              "Syarat & Ketentuan",
              const TermsPage(),
            ),
            _menuItem(
              context,
              Icons.privacy_tip_outlined,
              "Kebijakan Privasi",
              const PrivacyPolicyPage(),
            ),

            const SizedBox(height: 20),

            /// ================= LOGOUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Keluar",
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

  /// ================= TITLE =================
  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// ================= MENU =================
  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    String? trailing,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: Colors.black87),
              title: Text(title),
              trailing: trailing != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(trailing,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 14),
            ),
            const Divider(height: 0, indent: 56),
          ],
        ),
      ),
    );
  }
}