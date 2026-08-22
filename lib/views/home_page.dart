import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculator/calculator_page.dart';
import 'profile/profile_page.dart';
import 'calculator/pivot_point_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeContent(
        onCalculatorTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        },

        onPivotTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PivotPointPage(),
            ),
          );
        },

        onHistoryTap: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),

      CalculatorPage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),

      const HistoryPage(),

      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // BTM NAV
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

// BERANDA
class HomeContent extends StatefulWidget {
  final VoidCallback onCalculatorTap;
  final VoidCallback onPivotTap;
  final VoidCallback onHistoryTap;

  const HomeContent({
    super.key,
    required this.onCalculatorTap,
    required this.onPivotTap,
    required this.onHistoryTap,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // NAMA USER
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // AMBIL NAMA USER
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();

    final String? name =
        prefs.getString('displayName') ??
        prefs.getString('name') ??
        prefs.getString('username') ??
        prefs.getString('userName') ??
        prefs.getString('fullName');

    if (!mounted) return;

    setState(() {
      if (name != null && name.trim().isNotEmpty) {
        _userName = name.trim();
      } else {
        _userName = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          
          _buildHeader(),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              25,
              20,
              25,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WELCOME TEXT
                Text(
                  _userName.isNotEmpty
                      ? 'Selamat Datang, $_userName 👋'
                      : 'Selamat Datang 👋',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252525),
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Hitung nilai emas dengan mudah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B4B4B),
                    height: 1.35,
                  ),
                ),

                const Text(
                  'dan akurat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B4B4B),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TENTANG GOLDIFY
                // ==================================================

                _buildAboutCard(),

                const SizedBox(height: 25),

                // ==================================================
                // FITUR UTAMA
                // ==================================================

                const Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FITUR 1
                // ==================================================

                _buildFeatureCard(
                  icon: Icons.calculate_outlined,
                  title: 'Kalkulator Emas Fisik',
                  description:
                      'Konversi dan perhitungan akurat berdasarkan '
                      'Harga Beli (HB), Harga Jual (HJ), dan Modal Anda.',
                  onTap: widget.onCalculatorTap,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FITUR 2
                // ==================================================

                _buildFeatureCard(
                  icon: Icons.show_chart,
                  title: 'Analisis Pivot Point',
                  description:
                      'Strategi trading yang lebih baik dengan '
                      'kalkulasi level support dan resistance '
                      'harian secara otomatis.',
                  onTap: widget.onPivotTap,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FITUR 3
                // ==================================================

                _buildFeatureCard(
                  icon: Icons.history,
                  title: 'Riwayat Perhitungan',
                  description:
                      'Simpan dan organisir hasil perhitungan '
                      'Anda sebelumnya untuk referensi di masa mendatang.',
                  onTap: widget.onHistoryTap,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      color: Colors.white,
      child: Row(
        children: [
          // BTN BACK
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Hapus session login terlebih dahulu
                final prefs =
                    await SharedPreferences.getInstance();

                await prefs.remove('isLoggedIn');

                // Kembali ke halaman Login
                if (!mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: const Padding(
                padding: EdgeInsets.all(7),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 21,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),

          const SizedBox(width: 2),

          Image.asset(
            'assets/images/ewf.png',
            width: 43,
            height: 43,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'EQUITYWORLD FUTURES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
                color: Color(0xFF222222),
              ),
            ),
          ),

          const Icon(
            Icons.notifications_none_outlined,
            size: 27,
            color: Color(0xFF777777),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      height: 224,
      decoration: BoxDecoration(
        color: const Color(0xFFEFAE21),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEFAE21).withValues(
              alpha: 0.28,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          Positioned(
            top: -45,
            right: -12,
            child: Image.asset(
              'assets/images/gold.png',
              width: 120,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              19,
              12,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //TITLE
                Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD88D00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'Tentang Goldify',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // DESKRIPSI
                const Padding(
                  padding: EdgeInsets.only(
                    right: 2,
                  ),
                  child: Text(
                    'Goldify merupakan aplikasi digital yang '
                    'memudahkan Anda dalam melakukan '
                    'perhitungan emas fisik dan pivot '
                    'secara cepat dan efisien. Dengan '
                    'memasukkan harga beli, harga jual, '
                    'dan modal, sistem akan menampilkan '
                    'hasil perhitungan secara otomatis.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildTag(
                      icon: Icons.verified_user_outlined,
                      text: 'Aman',
                    ),

                    const SizedBox(width: 6),

                    _buildTag(
                      icon: Icons.visibility_outlined,
                      text: 'Transparan',
                    ),

                    const SizedBox(width: 6),

                    _buildTag(
                      icon: Icons.bolt_outlined,
                      text: 'Cepat',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTag({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.88,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF555555),
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 108,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.055,
                ),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFC87800),
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF292929),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF686868),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
                size: 27,
                color: Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//RIWAYAT
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