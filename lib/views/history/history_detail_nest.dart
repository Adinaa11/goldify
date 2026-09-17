import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calculator/nest_page.dart';

class HistoryDetailNestPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  const HistoryDetailNestPage({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<HistoryDetailNestPage> createState() =>
      _HistoryDetailNestPageState();
}

class _HistoryDetailNestPageState
    extends State<HistoryDetailNestPage> {
  static const Color orange =
      Color(0xFFF7931E);

  static const Color darkText =
      Color(0xFF222222);

  static const Color greyText =
      Color(0xFF666666);

  static const Color buyColor =
      Color(0xFF2E7D32);

  static const Color sellColor =
      Color(0xFFD32F2F);

  final ScreenshotController screenshotController =
      ScreenshotController();

  String _format(dynamic value) {
    final number = double.tryParse(
      value?.toString() ?? '',
    );

    if (number == null) {
      return '-';
    }

    return number
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final text = value.toString();

    if (text.length >= 16) {
      return text.substring(0, 16);
    }

    return text;
  }

  double _number(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _nestSignal(
    Map<String, dynamic> d,
  ) {
    final open = _number(
      d['open'],
    );

    final close = _number(
      d['close'],
    );

    if (close > open) {
      return 'BUY';
    }

    if (close < open) {
      return 'SELL';
    }

    return 'BUY / SELL';
  }

  Color _signalColor(String signal) {
    if (signal == 'BUY') {
      return buyColor;
    }

    if (signal == 'SELL') {
      return sellColor;
    }

    return orange;
  }

  String _signalExplanation(
    Map<String, dynamic> d,
  ) {
    final signal = _nestSignal(d);

    if (signal == 'BUY') {
      return 'Harga penutupan lebih tinggi dari harga pembukaan.\n'
          'Kondisi ini menunjukkan potensi kenaikan '
          'pada pergerakan harga berikutnya.';
    }

    if (signal == 'SELL') {
      return 'Harga penutupan lebih rendah dari harga pembukaan.\n'
          'Kondisi ini menunjukkan potensi penurunan '
          'pada pergerakan harga berikutnya.';
    }

    return 'Harga penutupan sama dengan harga pembukaan.\n'
        'Kondisi ini menunjukkan arah yang belum jelas.';
  }

  @override
  Widget build(BuildContext context) {
    final d = Map<String, dynamic>.from(
      widget.item['detail'] ?? {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(
          alpha: 0.20,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: orange,
            size: 21,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            children: [
              TextSpan(
                text: 'Riwayat Perhitungan ',
              ),
              TextSpan(
                text: 'NEST',
                style: TextStyle(
                  color: orange,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildMainResultCard(d),

                const SizedBox(
                  height: 16,
                ),

                _buildInputCard(d),

                const SizedBox(
                  height: 16,
                ),

                _buildComparisonCard(d),

                const SizedBox(
                  height: 16,
                ),

                _buildActionButtons(d),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainResultCard(
  Map<String, dynamic> d,
) {
  final signal = _nestSignal(d);
  final signalColor = _signalColor(signal);

  return Container(
    padding: const EdgeInsets.fromLTRB(
      16,
      12,
      16,
      18,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFCFA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFE6D7CA),
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.16,
                child: Image.asset(
                  'assets/images/ewf.jpg',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ==========================================
        // CONTENT DI ATAS WATERMARK
        // ==========================================
        Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: orange,
                  size: 21,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Hasil Perhitungan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'HASIL NEST',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                letterSpacing: 1,
                color: darkText,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              signal,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: signalColor,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: signal == 'BUY'
                    ? const Color(0xFFF1F8F2)
                    : signal == 'SELL'
                        ? const Color(0xFFFFF3F3)
                        : const Color(0xFFFFF8EF),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: signalColor.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Text(
                _signalExplanation(d),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: greyText,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              _formatDate(
                widget.item['date'],
              ),
              style: const TextStyle(
                fontSize: 11,
                color: greyText,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Data dari Riwayat',
                style: TextStyle(
                  fontSize: 10,
                  color: greyText,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildInputCard(
    Map<String, dynamic> d,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA INPUT',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _dataItem(
                'Open',
                d['open'],
              ),

              _dataItem(
                'Close',
                d['close'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataItem(
    String title,
    dynamic value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: greyText,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          _format(value),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    Map<String, dynamic> d,
  ) {
    final signal = _nestSignal(d);
    final signalColor = _signalColor(signal);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF3D2B0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'PERBANDINGAN HARGA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          _comparisonItem(
            'Close',
            'Harga Penutupan',
            d['close'],
          ),

          const SizedBox(
            height: 10,
          ),

          _comparisonItem(
            'Open',
            'Harga Pembukaan',
            d['open'],
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color: signalColor,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'INDIKATOR ACTION',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: greyText,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  signal,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: signalColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonItem(
    String title,
    String subtitle,
    dynamic value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: greyText,
                ),
              ),
            ],
          ),

          Text(
            _format(value),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    Map<String, dynamic> d,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _deleteHistory,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                  label: const Text(
                    'Hapus',
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NestPage(
                          initialData: d,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calculate_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Hitung Ulang',
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _download,
            icon: const Icon(
              Icons.download_outlined,
            ),
            label: const Text(
              'Download Hasil',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _download() async {
    try {
      final Uint8List image =
          await screenshotController
              .captureFromLongWidget(
        _buildDownloadWidget(),
        context: context,
        pixelRatio: 3,
      );

      final hasAccess =
          await Gal.hasAccess(
        toAlbum: true,
      );

      if (!hasAccess) {
        final granted =
            await Gal.requestAccess(
          toAlbum: true,
        );

        if (!granted) {
          throw Exception(
            'Izin galeri ditolak',
          );
        }
      }

      await Gal.putImageBytes(
        image,
        album: 'EWF NEST',
        name:
            'nest_history_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil NEST berhasil disimpan ke galeri',
          ),
          backgroundColor: orange,
          duration: Duration(
            seconds: 2,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan gambar: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDownloadWidget() {
    final d = Map<String, dynamic>.from(
      widget.item['detail'] ?? {},
    );

    final signal = _nestSignal(d);
    final signalColor = _signalColor(signal);

    return Material(
      color: Colors.white,
      child: Container(
        width: 420,
        padding: const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          28,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE6D7CA),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 55,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EWF • NEST INDICATOR',
                    style: TextStyle(
                      color: orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'HASIL PERHITUNGAN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _formatDate(
                      widget.item['date'],
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE6D7CA),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'HASIL NEST',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: greyText,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          signal,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: signalColor,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: signal == 'BUY'
                                ? const Color(0xFFF1F8F2)
                                : signal == 'SELL'
                                    ? const Color(0xFFFFF3F3)
                                    : const Color(0xFFFFF8EF),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: signalColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Text(
                            _signalExplanation(d),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: greyText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _downloadBox(
                    'DATA INPUT',
                    [
                      [
                        'Open',
                        d['open'],
                      ],
                      [
                        'Close',
                        d['close'],
                      ],
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _downloadComparison(d),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    'EWF NEST Calculator',
                    style: TextStyle(
                      fontSize: 10,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Analisa Lebih Mudah, '
                    'Trading Lebih Terarah',
                    style: TextStyle(
                      fontSize: 10,
                      color: greyText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Opacity(
                    opacity: 0.09,
                    child: Image.asset(
                      'assets/images/ewf.jpg',
                      width: 270,
                      height: 270,
                      fit: BoxFit.contain,
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

  Widget _downloadBox(
    String title,
    List<List<dynamic>> data,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E2E2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: darkText,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          ...data.map(
            (e) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 6,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e[0],
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    _format(e[1]),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadComparison(
    Map<String, dynamic> d,
  ) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF3D2B0),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'PERBANDINGAN HARGA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          _downloadBox(
            'Close',
            [
              [
                'Harga Penutupan',
                d['close'],
              ],
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          _downloadBox(
            'Open',
            [
              [
                'Harga Pembukaan',
                d['open'],
              ],
            ],
          ),

          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getStringList(
              'history_data',
            ) ??
            [];

    if (widget.index >= 0 &&
        widget.index < data.length) {
      data.removeAt(
        widget.index,
      );

      await prefs.setStringList(
        'history_data',
        data,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      {
        'deleted': true,
      },
    );
  }
}