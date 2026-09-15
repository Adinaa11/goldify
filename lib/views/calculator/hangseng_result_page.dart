import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hangseng_page.dart';

class HangsengResultPage extends StatefulWidget {
  final double open;
  final double high;
  final double low;
  final double close;
  final bool hasDecimalInput;
  final String? dataDate;
  final String? openInput;
  final String? highInput;
  final String? lowInput;
  final String? closeInput;

  const HangsengResultPage({
    super.key,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.hasDecimalInput,
    this.openInput,
    this.highInput,
    this.lowInput,
    this.closeInput,
    this.dataDate,
  });

  @override
  State<HangsengResultPage> createState() => _HangsengResultPageState();
}

class _HangsengResultPageState extends State<HangsengResultPage> {
  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF666666);
  static const Color lightBackground = Color(0xFFFFFCFA);
  static const Color resistanceBackground = Color(0xFFFFF7EF);
  static const Color resistanceBorder = Color(0xFFE8C9A9);
  static const Color supportBackground = Color(0xFFF7F9FA);
  static const Color supportBorder = Color(0xFFC9D8DD);
  static const Color midpointBackground = Color(0xFFF4F1EE);

  final ScreenshotController screenshotController =
      ScreenshotController();

  bool _showDetails = false;
  bool _historySaved = false;

  double get pp =>
      (widget.high + widget.low + widget.close) / 3;

  String get tradeSignal {
    if (widget.open > pp) return 'BUY';
    if (widget.open < pp) return 'SELL';
    return 'BUY / SELL';
  }

  Color get tradeSignalColor {
    switch (tradeSignal) {
      case 'BUY':
        return const Color(0xFF2E7D32);
      case 'SELL':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  IconData get tradeSignalIcon {
    switch (tradeSignal) {
      case 'BUY':
        return Icons.trending_up;
      case 'SELL':
        return Icons.trending_down;
      default:
        return Icons.remove;
    }
  }

  double get range =>
      widget.high - widget.low;

  double get r1 =>
      (2 * pp) - widget.low;

  double get r2 =>
      pp + range;

  double get r3 =>
      pp + (range * 2);

  double get r4 =>
      pp + (range * 3);

  double get s1 =>
      (2 * pp) - widget.high;

  double get s2 =>
      pp - range;

  double get s3 =>
      pp - (range * 2);

  double get s4 =>
      pp - (range * 3);

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
    final rounded = double.parse(value.toStringAsFixed(2));

    if (rounded == rounded.truncateToDouble()) {
      final number = rounded
          .toInt()
          .toString()
          .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => '.',
          );
      return number;
    }

    final parts = rounded.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '$integerPart,${parts[1]}';
  }

  String _formatInput(String? input, double fallback) {
    final text = input?.trim();

    if (text == null || text.isEmpty) {
      return _format(fallback);
    }

    if (text.contains(',')) {
      final parts = text.split(',');

      if (parts.length >= 2) {
        final integerText = parts[0].replaceAll('.', '');
        final integerValue = int.tryParse(integerText);

        if (integerValue != null) {
          final formattedInteger = integerValue
              .toString()
              .replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (match) => '.',
              );

          final decimalPart = parts.sublist(1).join(',');

          return '$formattedInteger,$decimalPart';
        }
      }

      return text;
    }

    final cleanText = text.replaceAll('.', '');

    final integerValue = int.tryParse(cleanText);

    if (integerValue != null) {
      return integerValue
          .toString()
          .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => '.',
          );
    }

    return text;
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

      final data = prefs.getStringList("history_data") ?? [];

      final historyDate =
          DateTime.now().toString().substring(0, 16);

      final item = {
        "type": "hangseng",
        "date": historyDate,
        "marketDate": widget.dataDate,
        "detail": {
          "open": widget.open,
          "high": widget.high,
          "low": widget.low,
          "close": widget.close,
          "openInput": widget.openInput,
          "highInput": widget.highInput,
          "lowInput": widget.lowInput,
          "closeInput": widget.closeInput,
          "pp": pp,
          "r1": r1,
          "r2": r2,
          "r3": r3,
          "r4": r4,
          "s1": s1,
          "s2": s2,
          "s3": s3,
          "s4": s4,
        },
        "result": tradeSignal,
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
          await Gal.hasAccess(toAlbum: true);

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
          _showDetails
              ? 'hangseng_detail_${DateTime.now().millisecondsSinceEpoch}'
              : 'hangseng_hasil_${DateTime.now().millisecondsSinceEpoch}';

      await Gal.putImageBytes(
        image,
        album: 'EWF Hangseng',
        name: fileName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _showDetails
                ? 'Hasil detail berhasil disimpan ke galeri.'
                : 'Hasil Hangseng berhasil disimpan ke galeri.',
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
                  opacity: 0.40,
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
          'EWF • HANGSENG',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: orange,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _showDetails
              ? 'HASIL DETAIL HANGSENG'
              : 'HASIL HANGSENG',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _showDetails
              ? 'Rincian Level Hangseng & Midpoint'
              : 'Rincian Level Hangseng',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: greyText,
          ),
        ),
        const SizedBox(height: 10),
        _buildTradeSignal(),
        const SizedBox(height: 18),
        _buildDownloadInput(),
        const SizedBox(height: 14),
        _buildDownloadResistance(),
        const SizedBox(height: 12),
        _buildDownloadPP(),
        const SizedBox(height: 12),
        _buildDownloadSupport(),
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
        borderRadius:
            BorderRadius.circular(9),
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
                'Open',
                _formatInput(
                  widget.openInput,
                  widget.open,
                ),
              ),
              _downloadInputItem(
                'High',
                _formatInput(
                  widget.highInput,
                  widget.high,
                ),
              ),
              _downloadInputItem(
                'Low',
                _formatInput(
                  widget.lowInput,
                  widget.low,
                ),
              ),
              _downloadInputItem(
                'Close',
                _formatInput(
                  widget.closeInput,
                  widget.close,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadInputItem(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: greyText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadResistance() {
    return _downloadSection(
      title: 'RESISTANCE',
      icon: Icons.trending_up,
      color: orange,
      background: resistanceBackground,
      border: resistanceBorder,
      children: [
        _downloadLevel('R4', r4),
        if (_showDetails)
          _downloadMid(
            'Midpoint R4 - R3',
            midpointR4R3,
          ),
        _downloadLevel('R3', r3),
        if (_showDetails)
          _downloadMid(
            'Midpoint R3 - R2',
            midpointR3R2,
          ),
        _downloadLevel('R2', r2),
        if (_showDetails)
          _downloadMid(
            'Midpoint R2 - R1',
            midpointR2R1,
          ),
        _downloadLevel('R1', r1),
        if (_showDetails)
          _downloadMid(
            'Midpoint R1 - PP',
            midpointR1PP,
          ),
      ],
    );
  }

  Widget _buildDownloadSupport() {
    return _downloadSection(
      title: 'SUPPORT',
      icon: Icons.trending_down,
      color: const Color(0xFF607D86),
      background: supportBackground,
      border: supportBorder,
      children: [
        _downloadLevel('S1', s1),
        if (_showDetails)
          _downloadMid(
            'Midpoint PP - S1',
            midpointPPS1,
          ),
        _downloadLevel('S2', s2),
        if (_showDetails)
          _downloadMid(
            'Midpoint S1 - S2',
            midpointS1S2,
          ),
        _downloadLevel('S3', s3),
        if (_showDetails)
          _downloadMid(
            'Midpoint S2 - S3',
            midpointS2S3,
          ),
        _downloadLevel('S4', s4),
        if (_showDetails)
          _downloadMid(
            'Midpoint S3 - S4',
            midpointS3S4,
          ),
      ],
    );
  }

  Widget _downloadSection({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
    required Color border,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background.withValues(
          alpha: 0.72,
        ),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...children,
        ],
      ),
    );
  }

  Widget _downloadLevel(
    String label,
    double value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.78,
        ),
        borderRadius:
            BorderRadius.circular(7),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            176,
            175,
            175,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadMid(
    String title,
    double value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 6,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: midpointBackground.withValues(
          alpha: 0.76,
        ),
        borderRadius:
            BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color.fromARGB(
                255,
                58,
                58,
                58,
              ),
            ),
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(
                255,
                79,
                79,
                79,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPP() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: orange,
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'HANGSENG (PP)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _format(pp),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required String title,
    required double value,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 5),
      padding:
          const EdgeInsets.symmetric(
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

  Widget _buildMidpointRow({
    required String title,
    required double value,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 7,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: midpointBackground,
        borderRadius:
            BorderRadius.circular(5),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            145,
            145,
            145,
          ),
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
          Row(
            children: [
              Expanded(
                child: _buildInputItem(
                  'Open',
                  _formatInput(
                    widget.openInput,
                    widget.open,
                  ),
                ),
              ),
              Expanded(
                child: _buildInputItem(
                  'High',
                  _formatInput(
                    widget.highInput,
                    widget.high,
                  ),
                ),
              ),
              Expanded(
                child: _buildInputItem(
                  'Low',
                  _formatInput(
                    widget.lowInput,
                    widget.low,
                  ),
                ),
              ),
              Expanded(
                child: _buildInputItem(
                  'Close',
                  _formatInput(
                    widget.closeInput,
                    widget.close,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputItem(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          _buildResultRow(
            title: 'R4',
            value: r4,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R4 - R3',
              value: midpointR4R3,
            ),
          _buildResultRow(
            title: 'R3',
            value: r3,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R3 - R2',
              value: midpointR3R2,
            ),
          _buildResultRow(
            title: 'R2',
            value: r2,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint R2 - R1',
              value: midpointR2R1,
            ),
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
          _buildResultRow(
            title: 'S1',
            value: s1,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint PP - S1',
              value: midpointPPS1,
            ),
          _buildResultRow(
            title: 'S2',
            value: s2,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint S1 - S2',
              value: midpointS1S2,
            ),
          _buildResultRow(
            title: 'S3',
            value: s3,
          ),
          if (_showDetails)
            _buildMidpointRow(
              title: 'Midpoint S2 - S3',
              value: midpointS2S3,
            ),
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

  Widget _buildTradeSignal() {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: tradeSignal == 'BUY'
              ? const Color(0xFFE8F5E9)
              : tradeSignal == 'SELL'
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFF5F5F5),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: tradeSignalColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tradeSignalIcon,
              size: 16,
              color: tradeSignalColor,
            ),
            const SizedBox(width: 6),
            Text(
              tradeSignal,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: tradeSignalColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            'HANGSENG',
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
            decoration: const BoxDecoration(
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
                    'HASIL HANGSENG',
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
                  child: Text(
                    _format(pp),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
                      color: orange,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                _buildTradeSignal(),
                const SizedBox(height: 7),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF5F2EF),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hangseng Terhitung',
                          style: TextStyle(
                            fontFamily:
                                'monospace',
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
                Text(
                  _showDetails
                      ? 'Rincian Level Hangseng & Midpoint'
                      : 'Rincian Level Hangseng',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 10),
                _buildResistanceSection(),
                const SizedBox(height: 12),
                _buildPivotPointBox(),
                const SizedBox(height: 8),
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
              style:
                  OutlinedButton.styleFrom(
                backgroundColor:
                    Colors.white,
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
              label: Text(
                _showDetails
                    ? 'Download Detail'
                    : 'Download Hasil',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
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
                        const HangsengPage(),
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor:
                    Colors.white,
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
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
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
                text: 'Hangseng',
                style: TextStyle(
                  color: orange,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
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
                  'Level Hangseng berdasarkan harga High, Low, dan Close pada periode yang dipilih.',
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