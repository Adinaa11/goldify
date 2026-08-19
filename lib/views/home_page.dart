import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    CalculatorPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: _pages[_selectedIndex],
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Beranda',
            index: 0,
          ),

          _buildNavItem(
            icon: Icons.calculate_outlined,
            label: 'Kalkulator',
            index: 1,
          ),

          _buildNavItem(
            icon: Icons.history,
            label: 'Riwayat',
            index: 2,
          ),

          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFFF7931E)
                  : Colors.grey,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? const Color(0xFFF7931E)
                    : Colors.grey,
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =========================================================
// HALAMAN BERANDA
// =========================================================

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'PT.EQUITY WORLD FUTURES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6B3F),
                    ),
                  ),
                ),

                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7931E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ISI HALAMAN
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WELCOME
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Brother 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF7931E),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Kelola dan lakukan perhitungan emas '
                  'dengan lebih mudah, cepat, dan efisien.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF4B5563),
                  ),
                ),

                const SizedBox(height: 24),

                // TENTANG GOLDIFY
                _buildAboutCard(),

                const SizedBox(height: 28),

                // FITUR UTAMA
                const Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 16),

                _buildFeatureCard(
                  icon: Icons.calculate_outlined,
                  title: 'Kalkulator Emas Fisik',
                  description:
                      'Konversi dan perhitungan berdasarkan harga beli, harga jual, kurs, dan modal.',
                  onTap: () {
                    // Nanti arahkan ke halaman
                    // Kalkulator Emas Fisik
                  },
                ),

                const SizedBox(height: 14),

                _buildFeatureCard(
                  icon: Icons.show_chart,
                  title: 'Analisis Pivot Point',
                  description:
                      'Strategi trading yang lebih baik dengan kalkulasi level support dan resistance.',
                  onTap: () {
                    // Nanti arahkan ke halaman
                    // Pivot Point
                  },
                ),

                const SizedBox(height: 14),

                _buildFeatureCard(
                  icon: Icons.history,
                  title: 'Riwayat Perhitungan',
                  description:
                      'Simpan dan lihat kembali hasil perhitungan untuk referensi Anda.',
                  onTap: () {
                    // Nanti arahkan ke halaman
                    // Riwayat
                  },
                ),

                const SizedBox(height: 28),

                // TIPS
                _buildTipsCard(),
              ],
            ),
          ),

          // GAMBAR BAWAH
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/bawah.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }

  // CARD TENTANG GOLDIFY
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8D5C0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE6CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF9C651E),
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Tentang Goldify',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Goldify merupakan aplikasi digital yang memudahkan '
            'Anda dalam melakukan perhitungan emas fisik dan '
            'analisis Pivot Point secara cepat dan efisien. '
            'Dengan memasukkan harga beli, harga jual, dan modal, '
            'sistem akan menampilkan hasil perhitungan secara otomatis.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildTag(
                icon: Icons.verified_user_outlined,
                text: 'Aman',
              ),

              const SizedBox(width: 8),

              _buildTag(
                icon: Icons.visibility_outlined,
                text: 'Transparan',
              ),

              const SizedBox(width: 8),

              _buildTag(
                icon: Icons.bolt_outlined,
                text: 'Cepat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAG
  Widget _buildTag({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.grey,
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // FEATURE CARD
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF7931E),
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // TIPS CARD
  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFF7931E),
            size: 28,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Hari Ini',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Perhatikan selisih harga beli dan harga jual '
                  'sebelum melakukan perhitungan potensi keuntungan.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// =========================================================
// HALAMAN KALKULATOR
// =========================================================

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Kalkulator',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


// =========================================================
// HALAMAN RIWAYAT
// =========================================================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Riwayat',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


// =========================================================
// HALAMAN PROFIL
// =========================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}