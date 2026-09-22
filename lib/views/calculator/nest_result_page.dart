import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nest_page.dart';

class NestResultPage extends StatefulWidget {
  final double? open;
  final double close;
  final bool hasDecimalInput;
  final String? dataDate;

  const NestResultPage({
    super.key,
    required this.open,
    required this.close,
    required this.hasDecimalInput,
    this.dataDate,
  });

  @override
  State<NestResultPage> createState() => _NestResultPageState();
}

class _NestResultPageState extends State<NestResultPage> {
  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF666666);
  static const Color lightBackground = Color(0xFFFFFCFA);

  final ScreenshotController screenshotController =
      ScreenshotController();

  bool _historySaved = false;

  String? get nestSignal {
    if (widget.open == null) {
      return null;
    }

    if (widget.open! > widget.close) {
      return 'SELL';
    }

    if (widget.open! < widget.close) {
      return 'BUY';
    }

    return 'BUY / SELL';
  }

  Color get nestSignalColor {
    switch (nestSignal) {
      case 'BUY':
        return const Color(0xFF2E7D32);

      case 'SELL':
        return const Color(0xFFD32F2F);

      default:
        return Colors.grey;
    }
  }

  String _format(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  String _formatOptional(double? value) {
    if (value == null) {
      return '-';
    }

    return _format(value);
  }

  @override
  void initState() {
    super.initState();
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    if (_historySaved) return;

    _historySaved = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      final data =
          prefs.getStringList("history_data") ?? [];

      final historyDate =
          DateTime.now()
              .toString()
              .substring(0, 16);

      final item = {
        "type": "nest",
        "date": historyDate,
        "marketDate": widget.dataDate,
        "detail": {
          "open": widget.open,
          "close": widget.close,
        },
        "result": nestSignal,
      };

      data.add(jsonEncode(item));

      await prefs.setStringList(
        "history_data",
        data,
      );
    } catch (_) {}
  }

  Future<void> _downloadResult(
    BuildContext context,
  ) async {
    try {
      final Uint8List image =
          await screenshotController.captureFromLongWidget(
        _buildDownloadWidget(),
        context: context,
        pixelRatio: 3.0,
        delay: const Duration(seconds: 1),
        constraints: const BoxConstraints(
          minWidth: 420,
          maxWidth: 420,
        ),
      );

      final bool hasAccess =
          await Gal.hasAccess(
        toAlbum: true,
      );

      if (!hasAccess) {
        final bool granted =
            await Gal.requestAccess(
          toAlbum: true,
        );

        if (!granted) {
          throw Exception(
            'Izin galeri tidak diberikan.',
          );
        }
      }

      final String fileName =
          'nest_hasil_${DateTime.now().millisecondsSinceEpoch}';

      await Gal.putImageBytes(
        image,
        album: 'EWF NEST',
        name: fileName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil NEST berhasil disimpan ke galeri.',
          ),
          backgroundColor: orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
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
    return Material(
      color: Colors.white,
      child: Container(
        width: 420,
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          32,
        ),
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildDownloadContent(),

            Transform.translate(
              offset: const Offset(0, -35),
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.20,
                  child: Image.asset(
                    'assets/images/ewf.jpg',
                    width: 180,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Text(
          'EWF • NEST INDICATOR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: orange,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'HASIL NEST',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Perbandingan Open Hari Ini & Close Kemarin',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: greyText,
          ),
        ),

        const SizedBox(height: 10),

        _buildDownloadInput(),

        const SizedBox(height: 14),

        _buildDownloadResult(),

        const SizedBox(height: 12),

        _buildDownloadExplanation(),
      ],
    );
  }

  Widget _buildDownloadInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.80,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA INPUT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: greyText,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _downloadInputItem(
                'Close',
                widget.close,
                'Kemarin',
              ),

              _downloadInputItem(
                'Open',
                widget.open,
                'Hari Ini',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadInputItem(
    String title,
    double? value,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: greyText,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          _formatOptional(value),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: orange,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'INDIKATOR ACTION',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          Text(
            nestSignal ?? '-',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: nestSignal == 'BUY'
                  ? const Color(0xFF2E7D32)
                  : nestSignal == 'SELL'
                      ? const Color(0xFFD32F2F)
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadExplanation() {
    String text;

    if (nestSignal == 'BUY') {
      text =
          'BUY — Open hari ini lebih rendah dari Close kemarin.';
    } else if (nestSignal == 'SELL') {
      text =
          'SELL — Open hari ini lebih tinggi dari Close kemarin.';
    } else if (nestSignal == 'BUY / SELL') {
      text =
          'BUY / SELL — Open hari ini sama dengan Close kemarin.';
    } else {
      text =
          'Open hari ini belum tersedia.';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1EE),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: greyText,
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String title,
    required String subtitle,
    required double? value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.8,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          Text(
            _formatOptional(value),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Input',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 25,
            runSpacing: 10,
            children: [
              _buildInputItem(
                'Close',
                widget.close,
              ),

              _buildInputItem(
                'Open',
                widget.open,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputItem(
    String label,
    double? value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          _formatOptional(value),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNestBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: orange,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'INDIKATOR ACTION',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          Text(
            nestSignal ?? '-',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: nestSignalColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: 0.20,
            child: Image.asset(
              'assets/images/ewf.jpg',
              width: 180,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationFrame() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE6D7CA),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: orange,
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 9,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: orange,
                      size: 20,
                    ),

                    SizedBox(width: 8),

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

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'INDIKATOR ACTION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Center(
                  child: Text(
                    nestSignal ?? '-',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: nestSignalColor,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EF),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: Colors.grey,
                        ),

                        SizedBox(width: 4),

                        Text(
                          'NEST Terhitung',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _buildInputSummary(),

                const SizedBox(height: 14),

                const Divider(
                  color: Color(0xFFE2D7CE),
                  thickness: 1,
                ),

                const SizedBox(height: 5),

                const Text(
                  'Perbandingan Harga',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 10),

                _buildResultRow(
                  title: 'Close',
                  subtitle: 'Harga Penutupan Kemarin',
                  value: widget.close,
                ),

                _buildResultRow(
                  title: 'Open',
                  subtitle: 'Harga Pembukaan Hari Ini',
                  value: widget.open,
                ),

                const SizedBox(height: 5),

                _buildNestBox(),

                const SizedBox(height: 8),

                _buildComparisonDescription(),
              ],
            ),
          ),

          _buildWatermark(),
        ],
      ),
    );
  }

  Widget _buildComparisonDescription() {
    String title;
    String description;

    if (nestSignal == 'BUY') {
      title = 'BUY';
      description =
          'Open hari ini lebih rendah dari Close kemarin.';
    } else if (nestSignal == 'SELL') {
      title = 'SELL';
      description =
          'Open hari ini lebih tinggi dari Close kemarin.';
    } else if (nestSignal == 'BUY / SELL') {
      title = 'BUY / SELL';
      description =
          'Open hari ini sama dengan Close kemarin.';
    } else {
      title = '-';
      description =
          'Open hari ini belum tersedia.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: nestSignalColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                _downloadResult(context);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: orange,
                side: const BorderSide(
                  color: orange,
                  width: 1.3,
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(
                Icons.download_outlined,
                size: 19,
              ),
              label: const Text(
                'Download Hasil',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(
                Icons.calculate_outlined,
                size: 19,
              ),
              label: const Text(
                'Hitung Lagi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor:
            Colors.black.withValues(
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
                text: 'Hasil Perhitungan ',
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
          50,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Indikator NEST berdasarkan perbandingan harga Close pada periode sebelumnya dengan harga Open pada periode berikutnya.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 20),

                Screenshot(
                  controller:
                      screenshotController,
                  child:
                      _buildCalculationFrame(),
                ),

                const SizedBox(height: 16),

                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}