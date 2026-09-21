import 'package:flutter/material.dart';

class HangsengInfoDialog extends StatelessWidget {
  const HangsengInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 650,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                12,
                18,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF8EF),
                    Color(0xFFFFE2BF),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // ICON CALCULATOR
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE7C5),
                          Color(0xFFFFC36F),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF7931E),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.candlestick_chart_outlined,
                      color: Color(0xFFE47700),
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // TITLE
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator Hangseng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Panduan Perhitungan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE47700),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    
                    const Text(
                      'Penjelasan Hangseng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Memahami komponen harga dan sinyal '
                      'perdagangan pada indeks Hangseng.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // PENJELASAN KOMPONEN
                    // =================================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF3C28D),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // HEADER KOMPONEN
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.fromLTRB(
                              14,
                              14,
                              14,
                              14,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF4E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color:
                                        Color(0xFFE47700),
                                    size: 21,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                const Expanded(
                                  child: Text(
                                    'Penjelasan Komponen',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Color(0xFFC86B00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                              14,
                              14,
                              14,
                              14,
                            ),
                            child: Column(
                              children: [
                                // OPEN
                                _buildComponent(
                                  letter: 'O',
                                  title: 'Open (Pembukaan)',
                                  description:
                                      'Harga indeks Hangseng pada saat '
                                      'sesi perdagangan dimulai.',
                                ),

                                const SizedBox(height: 14),

                                // HIGH
                                _buildComponent(
                                  letter: 'H',
                                  title: 'High (Tertinggi)',
                                  description:
                                      'Harga tertinggi yang dicapai oleh '
                                      'indeks Hangseng selama periode '
                                      'perdagangan yang digunakan.',
                                ),

                                const SizedBox(height: 14),

                                // LOW
                                _buildComponent(
                                  letter: 'L',
                                  title: 'Low (Terendah)',
                                  description:
                                      'Harga terendah yang dicapai oleh '
                                      'indeks Hangseng selama periode '
                                      'perdagangan yang digunakan.',
                                ),

                                const SizedBox(height: 14),

                                // CLOSE
                                _buildComponent(
                                  letter: 'C',
                                  title: 'Close (Penutupan)',
                                  description:
                                      'Harga indeks Hangseng pada saat '
                                      'sesi perdagangan berakhir.',
                                ),

                                const SizedBox(height: 16),

                                // BUY
                                _buildSignal(
                                  isBull: true,
                                  text: 'Jika Open > Hangseng',
                                  label: 'BUY',
                                ),

                                const SizedBox(height: 10),

                                // SELL
                                _buildSignal(
                                  isBull: false,
                                  text: 'Jika Open < Hangseng',
                                  label: 'SELL',
                                ),

                                const SizedBox(height: 10),

                                // NETRAL
                                _buildSignal(
                                  isBull: null,
                                  text: 'Jika Open = Hangseng',
                                  label: 'BUY or SELL',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFF7931E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildComponent({
    required String letter,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // BULATAN O/H/L/C
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF0F2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSignal({
    required bool? isBull,
    required String text,
    required String label,
  }) {
    final Color mainColor;
    final Color backgroundColor;
    final Color iconBackground;
    final IconData icon;

    if (isBull == true) {
      // BUY
      mainColor = const Color(0xFF16B364);
      backgroundColor = const Color(0xFFF1FBF5);
      iconBackground = const Color(0xFFE2F8EA);
      icon = Icons.trending_up;
    } else if (isBull == false) {
      // SELL
      mainColor = const Color(0xFFD20F39);
      backgroundColor = const Color(0xFFFFF2F4);
      iconBackground = const Color(0xFFFFE3E8);
      icon = Icons.trending_down;
    } else {
      // NETRAL
      mainColor = const Color(0xFF6B7280);
      backgroundColor = const Color(0xFFF5F6F7);
      iconBackground = const Color(0xFFE5E7EB);
      icon = Icons.remove;
    }

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
        border: Border(
          left: BorderSide(
            color: mainColor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),

          // ICON
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: mainColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // LABEL
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}