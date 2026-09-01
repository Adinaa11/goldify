import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import 'pivot_point_page.dart';

class PivotResultPage extends StatefulWidget {
  final double open;
  final double high;
  final double low;
  final double close;
  final bool hasDecimalInput;

  const PivotResultPage({
    super.key,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.hasDecimalInput,
  });

  @override
  State<PivotResultPage> createState() =>
      _PivotResultPageState();
}

class _PivotResultPageState extends State<PivotResultPage> {
 
  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF666666);

  static const Color lightBackground = Color(0xFFFFFCFA);

  // Resistance
  static const Color resistanceBackground = Color(0xFFFFF7EF);
  static const Color resistanceBorder = Color(0xFFE8C9A9);

  // Support
  static const Color supportBackground = Color(0xFFF7F9FA);
  static const Color supportBorder = Color(0xFFC9D8DD);

  // Midpoint
  static const Color midpointBackground = Color(0xFFF4F1EE);

  final ScreenshotController screenshotController =
      ScreenshotController();

  bool _showDetails = false;

  bool get _hasDecimalInput => widget.hasDecimalInput;
  
  // PIVOT POINT
  // PP = (High + Low + Close) / 3
  double get pp =>
      (widget.high + widget.low + widget.close) / 3;

  // High - Low
  double get range =>
       widget.high - widget.low;

  // RESISTANCE
  // R1 = 2 x PP - Low
  double get r1 =>
      (2 * pp) - widget.low;

  // R2 = PP + (High - Low)
  double get r2 =>
      pp + range;

  // R3 = PP + (High - Low) x 2
  double get r3 =>
      pp + (range * 2);

  // R4 = PP + (High - Low) x 3
  double get r4 =>
      pp + (range * 3);

  // SUPPORT
  // S1 = 2 x PP - High
  double get s1 =>
      (2 * pp) - widget.high;

  // S2 = PP - (High - Low)
  double get s2 =>
      pp - range;

  // S3 = PP - (High - Low) x 2
  double get s3 =>
      pp - (range * 2);

  // S4 = PP - (High - Low) x 3
  double get s4 =>
      pp - (range * 3);

  // MIDPOINT
  double get midpointR4R3 =>
      (r4 + r3) / 2;

  double get midpointR3R2 =>
      (r3 + r2) / 2;

  double get midpointR2R1 =>
      (r2 + r1) / 2;

  double get midpointR1PP =>
      (r1 + pp) / 2;

  double get midpointPPS1 =>
      (pp + s1) / 2;

  double get midpointS1S2 =>
      (s1 + s2) / 2;

  double get midpointS2S3 =>
      (s2 + s3) / 2;

  double get midpointS3S4 =>
      (s3 + s4) / 2;

  String _format(double value) {
    if (_hasDecimalInput) {
      return value
          .toStringAsFixed(2)
          .replaceAll('.', ',');
    }

    return value.round().toString();
  }

  // SAVE HISTORY
  Future<void> _saveHistory(
    BuildContext context,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final String historyItem =
        'High: ${_format(widget.high)} | '
        'Low: ${_format(widget.low)} | '
        'Close: ${_format(widget.close)} | '
        'PP: ${_format(pp)}';

    final List<String> history =
        prefs.getStringList('pivot_history') ?? [];

    history.insert(0, historyItem);

    await prefs.setStringList(
      'pivot_history',
      history,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Perhitungan berhasil disimpan ke riwayat.',
        ),
        backgroundColor: orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _downloadResult(
    BuildContext context,
  ) async {
    try {
      // Pastikan UI terbaru sudah selesai dirender
      await Future.delayed(
        const Duration(milliseconds: 150),
      );

      final Uint8List? image =
          await screenshotController.capture(
        pixelRatio: 3,
      );

      if (image == null) {
        throw Exception(
          'Gagal mengambil gambar.',
        );
      }

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

      final String fileName = _showDetails
          ? 'pivot_detail_${DateTime.now().millisecondsSinceEpoch}'
          : 'pivot_ringkasan_${DateTime.now().millisecondsSinceEpoch}';

      await Gal.putImageBytes(
        image,
        album: 'EWF Pivot',
        name: fileName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _showDetails
                ? 'Hasil detail berhasil disimpan ke galeri.'
                : 'Hasil ringkasan berhasil disimpan ke galeri.',
          ),
          backgroundColor: orange,
          duration: const Duration(seconds: 2),
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

  // RESULT ROW
  Widget _buildResultRow({
    required String title,
    required double value,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
          Text(
            _format(value),
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

  // MIDPOINT ROW
  Widget _buildMidpointRow({
    required String title,
    required double value,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 7,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: midpointBackground,
        borderRadius:
            BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.remove,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: greyText,
                ),
              ),
            ],
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSummary() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(6),
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

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _buildInputItem(
                'High',
                widget.high,
              ),
              _buildInputItem(
                'Low',
                widget.low,
              ),
              _buildInputItem(
                'Close',
                widget.close,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputItem(
    String label,
    double value,
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
          _format(value),
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

  // RESISTANCE
  Widget _buildResistanceSection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        10,
        12,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: resistanceBackground,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: resistanceBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_up,
                color: orange,
                size: 17,
              ),
              SizedBox(width: 6),
              Text(
                'RESISTANCE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: orange,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // R4
          _buildResultRow(
            title: 'R4',
            value: r4,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R4 - R3',
              value: midpointR4R3,
            ),

          // R3
          _buildResultRow(
            title: 'R3',
            value: r3,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R3 - R2',
              value: midpointR3R2,
            ),

          // R2
          _buildResultRow(
            title: 'R2',
            value: r2,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R2 - R1',
              value: midpointR2R1,
            ),

          // R1
          _buildResultRow(
            title: 'R1',
            value: r1,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R1 - PP',
              value: midpointR1PP,
            ),
        ],
      ),
    );
  }

  // SUPPORT
  Widget _buildSupportSection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        10,
        12,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: supportBackground,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: supportBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_down,
                color: Color(0xFF607D86),
                size: 17,
              ),
              SizedBox(width: 6),
              Text(
                'SUPPORT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF607D86),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // S1
          _buildResultRow(
            title: 'S1',
            value: s1,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint PP - S1',
              value: midpointPPS1,
            ),

          // S2
          _buildResultRow(
            title: 'S2',
            value: s2,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint S1 - S2',
              value: midpointS1S2,
            ),

          // S3
          _buildResultRow(
            title: 'S3',
            value: s3,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint S2 - S3',
              value: midpointS2S3,
            ),

          // S4
          _buildResultRow(
            title: 'S4',
            value: s4,
          ),

          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint S3 - S4',
              value: midpointS3S4,
            ),
        ],
      ),
    );
  }

  // PP BOX
  Widget _buildPivotPointBox() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DF),
        borderRadius:
            BorderRadius.circular(8),
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
            'PIVOT POINT (PP)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          Text(
            _format(pp),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: orange,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          minimumSize: Size.zero,
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          _showDetails
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          size: 18,
        ),
        label: Text(
          _showDetails
              ? 'Kembali ke Ringkasan'
              : 'Lihat Detail',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

 // WATERMARK
  Widget _buildWatermark() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: 0.50,
            child: Image.asset(
              'assets/images/ewf.png',
              width: 270,
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

      padding:
          const EdgeInsets.fromLTRB(
        12,
        12,
        10,
        10,
      ),

      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE6D7CA),
          width: 1,
        ),
      ),

      child: Stack(
        children: [

          Container(
            decoration:
                const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: orange,
                  width: 3,
                ),
              ),
            ),

            padding:
                const EdgeInsets.only(
              left: 9,
              right: 0,
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
                        fontWeight:
                            FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'HASIL PIVOT POINT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Center(
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: orange,
                        size: 25,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _format(pp),
                        style:
                            const TextStyle(
                          fontFamily:
                              'monospace',
                          fontSize: 34,
                          fontWeight:
                              FontWeight.bold,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 7),

                // STATUS
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF5F2EF,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .check_circle_outline,
                          size: 12,
                          color:
                              Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pivot Point Terhitung',
                          style: TextStyle(
                            fontFamily:
                                'monospace',
                            fontSize: 9,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // INPUT DATA
                _buildInputSummary(),

                const SizedBox(height: 14),

                const Divider(
                  color:
                      Color(0xFFE2D7CE),
                  thickness: 1,
                ),

                const SizedBox(height: 5),

                Text(
                  _showDetails
                      ? 'Rincian Level Pivot & Midpoint'
                      : 'Rincian Level Pivot',
                  style: const TextStyle(
                    fontFamily:
                        'monospace',
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 10),

                // RESISTANCE
                _buildResistanceSection(),

                const SizedBox(height: 12),

                // PIVOT POINT
                _buildPivotPointBox(),

                const SizedBox(height: 8),

                // SUPPORT
                _buildSupportSection(),

                const SizedBox(height: 3),

                _buildDetailToggle(),
              ],
            ),
          ),

          _buildWatermark(),
        ],
      ),
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
                text: 'Hasil Perhitungan ',
              ),
              TextSpan(
                text: 'Pivot',
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
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text(
                  'Level Pivot Point berdasarkan harga '
                  'High, Low, dan Close pada periode yang '
                  'dipilih.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 20),

                Screenshot(
                  controller: screenshotController,
                  child: _buildCalculationFrame(),
                ),

                const SizedBox(height: 16),

                // DOWNLOAD
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      _downloadResult(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.download_outlined,
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _showDetails
                              ? 'Download Detail'
                              : 'Download Hasil',

                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // SIMPAN RIWAYAT
                SizedBox(
                  width: double.infinity,
                  height: 44,

                  child: OutlinedButton(
                    onPressed: () {
                      _saveHistory(context);
                    },

                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: orange,

                      side: const BorderSide(
                        color: orange,
                        width: 1.2,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_outlined,
                          size: 19,
                        ),

                        SizedBox(width: 8),

                        Text(
                          'Simpan Riwayat',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // HITUNG LAGI
                SizedBox(
                  width: double.infinity,
                  height: 44,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PivotPointPage(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calculate,
                          size: 19,
                        ),

                        SizedBox(width: 7),

                        Text(
                          'Hitung Lagi',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}