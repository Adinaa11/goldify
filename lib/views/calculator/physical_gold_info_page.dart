import 'package:flutter/material.dart';

class PhysicalGoldInfoDialog extends StatelessWidget {
  const PhysicalGoldInfoDialog({super.key});

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
            //HEADER POP-UP
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
                  // ICON
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
                      Icons.calculate_outlined,
                      color: Color(0xFFE47700),
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // TITLE
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator Emas Fisik',
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

            // ISI POP-UP
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DESKRIPSI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF3D4B0),
                        ),
                      ),
                      child: const Text(
                        'Ikuti 5 langkah matematis di bawah ini '
                        'untuk memahami cara menghitung potensi '
                        'keuntungan atau kerugian (Profit/Loss) '
                        'pada investasi emas fisik Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LANGKAH 1
                    _buildStep(
                      number: '1',
                      title: 'Menghitung Harga Beli',
                      description:
                          'Gunakan harga beli (Harga Beli) dan kurs untuk '
                          'mendapatkan nilai harga beli per Troy Ounce (TOz).',
                      formula: 'Harga Beli × Kurs\n────────────\n     31.1',
                    ),

                    const SizedBox(height: 14),

                    // LANGKAH 2
                    _buildStep(
                      number: '2',
                      title: 'Menghitung Harga Jual',
                      description:
                          'Gunakan harga jual (Harga Jual) dan kurs untuk '
                          'mendapatkan nilai harga jual per Troy Ounce (TOz).',
                      formula: 'Harga Jual × Kurs\n────────────\n     31.1',
                    ),

                    const SizedBox(height: 14),

                    // LANGKAH 3
                    _buildStep(
                      number: '3',
                      title: 'Menghitung Selisih Harga',
                      description:
                          'Hitung selisih antara hasil harga jual '
                          'dan hasil harga beli.',
                      formula:
                          'Hasil Harga Jual (Langkah 2)\n− Hasil Harga Beli (Langkah 1)',
                    ),

                    const SizedBox(height: 14),

                    // LANGKAH 4
                    _buildStep(
                      number: '4',
                      title: 'Menghitung Jumlah Emas',
                      description:
                          'Gunakan modal yang dimiliki untuk mengetahui '
                          'jumlah emas berdasarkan hasil harga beli.',
                      formula:
                          'Modal\n────────────\nHasil Harga Beli (Langkah 1)',
                    ),

                    const SizedBox(height: 14),

                    // LANGKAH 5
                    _buildStep(
                      number: '5',
                      title: 'Menghitung Profit / Loss',
                      description:
                          'Kalikan selisih harga dengan jumlah emas '
                          'yang diperoleh pada Langkah 4.',
                      formula:
                          'Hasil Langkah 3\n× Hasil Langkah 4',
                      isFinal: true,
                    ),

                    const SizedBox(height: 18),

                    // CATATAN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF5D5A8),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFF7931E),
                            size: 22,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'Hasil akhir dapat menunjukkan potensi '
                              'keuntungan (Profit) atau kerugian (Loss) '
                              'berdasarkan perbedaan harga beli dan harga jual.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // TOMBOL TUTUP
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
                    backgroundColor: const Color(0xFFF7931E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  // WIDGET LANGKAH
  static Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required String formula,
    bool isFinal = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFinal
            ? const Color(0xFFFFF4E5)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFinal
              ? const Color(0xFFF7931E)
              : const Color(0xFFE5E7EB),
          width: isFinal ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOMOR + JUDUL
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7931E),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'LANGKAH $number: $title',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // DESKRIPSI
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 12),

          // RUMUS DENGAN BORDER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFinal
                    ? const Color(0xFFF7931E)
                    : const Color(0xFFF3C28D),
                width: 1.2,
              ),
            ),
            child: Text(
              formula,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}