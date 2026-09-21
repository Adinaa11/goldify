import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: const Text(
          "Syarat & Ketentuan",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          const SizedBox(height: 30),

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
                  "Syarat & Ketentuan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "1. Ketentuan Umum",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Dengan menggunakan aplikasi Goldify, pengguna dianggap "
                          "telah membaca, memahami, dan menyetujui seluruh syarat "
                          "serta ketentuan penggunaan aplikasi. Pengguna wajib "
                          "menggunakan aplikasi secara bertanggung jawab dan tidak "
                          "menyalahgunakan fitur yang tersedia.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "2. Penggunaan Layanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Goldify menyediakan berbagai fitur perhitungan dan "
                          "analisis terkait emas, seperti Kalkulator Emas Fisik, "
                          "Pivot Point Emas, Perhitungan Hangseng, Indikator NEST, "
                          "Historical Data, dan Riwayat Perhitungan.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "3. Informasi dan Hasil Perhitungan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Hasil perhitungan yang diberikan oleh Goldify merupakan "
                          "informasi pendukung dan alat bantu analisis. Hasil "
                          "tersebut tidak dapat dianggap sebagai rekomendasi "
                          "investasi, keputusan transaksi, maupun jaminan hasil "
                          "keuntungan tertentu.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "4. Data Pengguna",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Pengguna bertanggung jawab atas informasi yang diberikan "
                          "dalam aplikasi. Data tertentu dapat digunakan untuk "
                          "mendukung fungsi aplikasi seperti penyimpanan profil "
                          "dan riwayat perhitungan pengguna.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "5. Perubahan Layanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Goldify berhak melakukan pengembangan, perubahan fitur, "
                          "maupun pembaruan layanan untuk meningkatkan kualitas "
                          "dan pengalaman pengguna.",
                          style: TextStyle(
                            fontSize: 13,
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
          ),

          // ================= BUTTON =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // ⬅️ kembali
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7931E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Saya Mengerti",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}