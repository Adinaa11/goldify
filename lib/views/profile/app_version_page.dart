import 'package:flutter/material.dart';
import '../../viewmodels/app_version_viewmodel.dart';

class AppVersionPage extends StatelessWidget {
  AppVersionPage({super.key});

  final AppVersionViewModel viewModel = AppVersionViewModel();

  @override
  Widget build(BuildContext context) {
    final data = viewModel.appVersion;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFF7931E),
        ),
        title: const Text(
          "Tentang Goldify",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            // LOGO
            Center(
              child: Column(
                children: [

                  Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Aplikasi Perhitungan Emas Digital",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD INFORMASI
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [

                  const ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Color(0xFFF7931E),
                    ),

                    title: Text(
                      "Tentang Goldify",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "Goldify merupakan aplikasi digital untuk membantu "
                      "pengguna melakukan perhitungan dan analisis pasar "
                      "emas secara mudah dan efisien. Aplikasi ini "
                      "menyediakan berbagai fitur seperti kalkulator "
                      "emas fisik, Pivot Emas, perhitungan Hangseng, serta "
                      "indikator NEST yang dapat digunakan sebagai alat "
                      "bantu dalam memahami pergerakan dan nilai emas.",
                    ),
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(
                      Icons.star_outline,
                      color: Color(0xFFF7931E),
                    ),

                    title: Text(
                      "Fitur Utama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "• Kalkulator Emas Fisik\n"
                      "• Pivot Point Emas\n"
                      "• Perhitungan Pivot Hangseng\n"
                      "• Indikator NEST\n"
                      "• Historical Data\n"
                      "• Riwayat Perhitungan",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Informasi Pengembang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Goldify Team",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Aplikasi ini dikembangkan untuk "
                    "membantu pengguna dalam melakukan "
                    "perhitungan emas secara mudah dan cepat.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}