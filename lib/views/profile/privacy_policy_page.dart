import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  void _handleAgree(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Anda telah membaca Kebijakan Privasi"),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 800),
      ), 
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pop(context);
    });
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
          "Kebijakan Privasi",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          // LOGO
          Column(
            children: [
              Image.asset('assets/images/gold.png', width: 80),
              const SizedBox(height: 10),
              const Text(
                "Kebijakan Privasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "1. Pendahuluan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Goldify menghargai privasi pengguna dan berkomitmen "
                      "untuk menjaga keamanan informasi yang digunakan "
                      "dalam aplikasi. Kebijakan Privasi ini menjelaskan "
                      "bagaimana data pengguna dikumpulkan, digunakan, "
                      "dan dilindungi selama menggunakan aplikasi Goldify.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "2. Data yang Dikumpulkan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Goldify dapat mengumpulkan beberapa informasi "
                      "untuk mendukung fungsi aplikasi, seperti:\n\n"
                      "• Informasi akun pengguna (nama dan email)\n"
                      "• Informasi profil pengguna\n"
                      "• Foto profil yang diunggah pengguna\n"
                      "• Riwayat hasil perhitungan yang tersimpan\n"
                      "• Data penggunaan fitur aplikasi",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "3. Penggunaan Data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Data pengguna digunakan untuk mendukung layanan "
                      "aplikasi, seperti menampilkan informasi profil, "
                      "menyimpan riwayat perhitungan, serta mendukung "
                      "penggunaan fitur Kalkulator Emas Fisik, Pivot Point, "
                      "Hangseng, dan Indikator NEST.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "4. Penyimpanan dan Keamanan Data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Goldify berupaya menjaga keamanan data pengguna "
                      "dengan menerapkan langkah perlindungan yang sesuai. "
                      "Data pengguna tidak digunakan untuk tujuan di luar "
                      "fungsi layanan aplikasi tanpa persetujuan pengguna.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "5. Hak Pengguna",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Pengguna memiliki hak untuk memperbarui informasi "
                      "profil yang tersedia pada aplikasi serta mengelola "
                      "penggunaan layanan sesuai dengan fitur yang tersedia.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "6. Perubahan Kebijakan Privasi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Goldify dapat melakukan perubahan terhadap "
                      "Kebijakan Privasi apabila diperlukan untuk "
                      "menyesuaikan perkembangan fitur dan peningkatan "
                      "layanan aplikasi.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _handleAgree(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7931E),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Saya Mengerti",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}