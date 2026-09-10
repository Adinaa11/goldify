import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calculator/hangseng_page.dart';

class HistoryDetailHangsengPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  const HistoryDetailHangsengPage({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<HistoryDetailHangsengPage> createState() =>
      _HistoryDetailHangsengPageState();
}

class _HistoryDetailHangsengPageState
    extends State<HistoryDetailHangsengPage> {
  static const Color orange = Color(0xFFF7931E);
  static const Color darkText = Color(0xFF222222);
  static const Color greyText = Color(0xFF666666);

  static const Color lightBackground = Color(0xFFFFFCFA);
  static const Color resistanceBackground = Color(0xFFFFF7EF);
  static const Color resistanceBorder = Color(0xFFE8C9A9);

  static const Color supportBackground = Color(0xFFF7F9FA);
  static const Color supportBorder = Color(0xFFC9D8DD);

  static const Color midpointBackground = Color(0xFFF1F1F1);

  static const Color buyColor = Color(0xFF2E7D32);
  static const Color sellColor = Color(0xFFD32F2F);

  bool showDetail = false;

  final ScreenshotController screenshotController =
      ScreenshotController();

  String _format(dynamic value) {
    final number = double.tryParse(
      value?.toString() ?? '',
    );

    if (number == null) {
      return '-';
    }

    final fixed = number.toStringAsFixed(2);
    final parts = fixed.split('.');

    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return '$integerPart,${parts[1]}';
  }

  String _formatInput(
    dynamic original,
    dynamic fallback,
  ) {
    final text = original?.toString().trim();

    if (text == null || text.isEmpty) {
      return _format(fallback);
    }

    // Format dengan koma sebagai desimal.
    // Contoh:
    // 25264,00 -> 25.264,00
    // 25264,50 -> 25.264,50
    if (text.contains(',')) {
      final parts = text.split(',');

      if (parts.length >= 2) {
        final integerPart = parts[0]
            .replaceAll('.', '')
            .replaceAll(' ', '');

        final decimalPart = parts
            .sublist(1)
            .join(',')
            .replaceAll(' ', '');

        final integerValue = int.tryParse(integerPart);

        if (integerValue != null) {
          final groupedInteger = integerValue
              .toString()
              .replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (_) => '.',
              );

          return '$groupedInteger,$decimalPart';
        }
      }

      return text;
    }

    // Jika tidak ada koma dan berupa angka bulat.
    // Contoh:
    // 25264 -> 25.264
    final cleanText = text
        .replaceAll('.', '')
        .replaceAll(' ', '');

    final integerValue = int.tryParse(cleanText);

    if (integerValue != null) {
      return integerValue
          .toString()
          .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (_) => '.',
          );
    }

    // Jika format tidak dikenali, tampilkan apa adanya.
    return text;
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

  double _calcMid(dynamic a, dynamic b) {
    return (_number(a) + _number(b)) / 2;
  }

  String _tradeSignal(Map<String, dynamic> d) {
    final pp = _number(d['pp']);
    final open = _number(d['open']);

    if (open > pp) {
      return 'BUY';
    }

    if (open < pp) {
      return 'SELL';
    }

    return 'BOTH';
  }

  @override
  Widget build(BuildContext context) {
    final d = Map<String, dynamic>.from(
      widget.item['detail'] ?? {},
    );

    final date = widget.item['date'];

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainResultCard(
                  d,
                  date,
                ),
                const SizedBox(height: 16),
                _buildInputCard(d),
                const SizedBox(height: 16),
                _buildLevelContent(d),
                const SizedBox(height: 4),
                _buildDetailToggle(),
                const SizedBox(height: 14),
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
    dynamic date,
  ) {
    final signal = _tradeSignal(d);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6D7CA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Opacity(
                      opacity: 0.40,
                      child: Image.asset(
                        'assets/images/ewf.jpg',
                        width: 270,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  const Center(
                    child: Text(
                      'HASIL HANGSENG',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Color.fromARGB(
                          255,
                          50,
                          50,
                          50,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _format(d['pp']),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(
                          255,
                          243,
                          130,
                          0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color.fromARGB(
                          255,
                          77,
                          76,
                          76,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTradeSignal(signal),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 12,
                            color: greyText,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Data dari Riwayat',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            color: Color(0xFFE2D7CE),
            thickness: 1,
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: orange,
                size: 21,
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
          const SizedBox(height: 12),
          const Text(
            'Rincian Level Hangseng',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeSignal(String signal) {
    if (signal == 'BUY') {
      return _signalBadge(
        text: 'BUY',
        color: buyColor,
        background: const Color(0xFFE8F5E9),
        icon: Icons.trending_up,
      );
    }

    if (signal == 'SELL') {
      return _signalBadge(
        text: 'SELL',
        color: sellColor,
        background: const Color(0xFFFFEBEE),
        icon: Icons.trending_down,
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: orange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz,
              size: 17,
              color: orange,
            ),
            const SizedBox(width: 6),
            const Text(
              'BUY',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: buyColor,
              ),
            ),
            const Text(
              ' / ',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: greyText,
              ),
            ),
            const Text(
              'SELL',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: sellColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signalBadge({
    required String text,
    required Color color,
    required Color background,
    required IconData icon,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(
    Map<String, dynamic> d,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataItem(
                'Open',
                d['openInput'],
                d['open'],
              ),
              _dataItem(
                'High',
                d['highInput'],
                d['high'],
              ),
              _dataItem(
                'Low',
                d['lowInput'],
                d['low'],
              ),
              _dataItem(
                'Close',
                d['closeInput'],
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
    dynamic original,
    dynamic fallback,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: greyText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _formatInput(
            original,
            fallback,
          ),
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

  Widget _buildLevelContent(
    Map<String, dynamic> d,
  ) {
    return Column(
      children: [
        _section(
          title: 'RESISTANCE',
          color: orange,
          background: resistanceBackground,
          border: resistanceBorder,
          icon: Icons.trending_up,
          children: [
            _level('R4', d['r4']),
            if (showDetail)
              _mid(
                'Midpoint R4 - R3',
                _calcMid(
                  d['r4'],
                  d['r3'],
                ),
              ),
            _level('R3', d['r3']),
            if (showDetail)
              _mid(
                'Midpoint R3 - R2',
                _calcMid(
                  d['r3'],
                  d['r2'],
                ),
              ),
            _level('R2', d['r2']),
            if (showDetail)
              _mid(
                'Midpoint R2 - R1',
                _calcMid(
                  d['r2'],
                  d['r1'],
                ),
              ),
            _level('R1', d['r1']),
            if (showDetail)
              _mid(
                'Midpoint R1 - PP',
                _calcMid(
                  d['r1'],
                  d['pp'],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPivotPointBox(d),
        const SizedBox(height: 12),
        _section(
          title: 'SUPPORT',
          color: const Color(0xFF607D86),
          background: supportBackground,
          border: supportBorder,
          icon: Icons.trending_down,
          children: [
            _level('S1', d['s1']),
            if (showDetail)
              _mid(
                'Midpoint PP - S1',
                _calcMid(
                  d['pp'],
                  d['s1'],
                ),
              ),
            _level('S2', d['s2']),
            if (showDetail)
              _mid(
                'Midpoint S1 - S2',
                _calcMid(
                  d['s1'],
                  d['s2'],
                ),
              ),
            _level('S3', d['s3']),
            if (showDetail)
              _mid(
                'Midpoint S2 - S3',
                _calcMid(
                  d['s2'],
                  d['s3'],
                ),
              ),
            _level('S4', d['s4']),
            if (showDetail)
              _mid(
                'Midpoint S3 - S4',
                _calcMid(
                  d['s3'],
                  d['s4'],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required Color color,
    required Color background,
    required Color border,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        10,
        12,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _level(
    String label,
    dynamic value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
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

  Widget _mid(
    String label,
    double value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: midpointBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: greyText,
            ),
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPivotPointBox(
    Map<String, dynamic> d,
  ) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            _format(d['pp']),
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
            showDetail = !showDetail;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: orange,
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 1,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          showDetail
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          size: 15,
        ),
        label: Text(
          showDetail
              ? 'Sembunyikan Detail'
              : 'Lihat Detail',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HangsengPage(
                          initialData: d,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  icon: const Icon(
                    Icons.calculate_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Hitung Ulang',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _download,
            style: OutlinedButton.styleFrom(
              foregroundColor: orange,
              side: const BorderSide(
                color: orange,
                width: 1.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            icon: const Icon(
              Icons.download_outlined,
              size: 19,
            ),
            label: Text(
              showDetail
                  ? 'Download Detail'
                  : 'Download Hasil',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadWidget() {
    final d = Map<String, dynamic>.from(
      widget.item['detail'] ?? {},
    );

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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.70,
              child: Image.asset(
                'assets/images/ewf.jpg',
                width: 330,
                fit: BoxFit.contain,
              ),
            ),
            _buildDownloadContent(d),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadContent(
    Map<String, dynamic> d,
  ) {
    final signal = _tradeSignal(d);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'EWF • RIWAYAT HANGSENG',
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
          'HASIL PERHITUNGAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(widget.item['date']),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: greyText,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.68,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE2E2E2),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'HANGSENG POINT',
                style: TextStyle(
                  fontSize: 11,
                  color: greyText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _format(d['pp']),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: orange,
                ),
              ),
              const SizedBox(height: 8),
              _buildTradeSignalDownload(signal),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _downloadInputCard(d),
        const SizedBox(height: 12),
        _downloadHistorySection(
          title: 'RESISTANCE',
          color: orange,
          background: resistanceBackground,
          border: resistanceBorder,
          values: [
            ['R4', d['r4']],
            ['R3', d['r3']],
            ['R2', d['r2']],
            ['R1', d['r1']],
          ],
          midpoints: [
            [
              'Midpoint R4 - R3',
              _calcMid(
                d['r4'],
                d['r3'],
              ),
            ],
            [
              'Midpoint R3 - R2',
              _calcMid(
                d['r3'],
                d['r2'],
              ),
            ],
            [
              'Midpoint R2 - R1',
              _calcMid(
                d['r2'],
                d['r1'],
              ),
            ],
            [
              'Midpoint R1 - PP',
              _calcMid(
                d['r1'],
                d['pp'],
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
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
                'HANGSENG POINT (PP)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _format(d['pp']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _downloadHistorySection(
          title: 'SUPPORT',
          color: const Color(0xFF607D86),
          background: supportBackground,
          border: supportBorder,
          values: [
            ['S1', d['s1']],
            ['S2', d['s2']],
            ['S3', d['s3']],
            ['S4', d['s4']],
          ],
          midpoints: [
            [
              'Midpoint PP - S1',
              _calcMid(
                d['pp'],
                d['s1'],
              ),
            ],
            [
              'Midpoint S1 - S2',
              _calcMid(
                d['s1'],
                d['s2'],
              ),
            ],
            [
              'Midpoint S2 - S3',
              _calcMid(
                d['s2'],
                d['s3'],
              ),
            ],
            [
              'Midpoint S3 - S4',
              _calcMid(
                d['s3'],
                d['s4'],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'EWF Hangseng Calculator',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildTradeSignalDownload(
    String signal,
  ) {
    if (signal == 'BUY') {
      return _signalBadge(
        text: 'BUY',
        color: buyColor,
        background: const Color(0xFFE8F5E9),
        icon: Icons.trending_up,
      );
    }

    if (signal == 'SELL') {
      return _signalBadge(
        text: 'SELL',
        color: sellColor,
        background: const Color(0xFFFFEBEE),
        icon: Icons.trending_down,
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.92,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: orange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz,
              size: 17,
              color: orange,
            ),
            const SizedBox(width: 6),
            const Text(
              'BUY',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: buyColor,
              ),
            ),
            const Text(
              ' / ',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: greyText,
              ),
            ),
            const Text(
              'SELL',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: sellColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _downloadInputCard(
    Map<String, dynamic> d,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.68,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE2E2E2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA INPUT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: greyText,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _downloadInput(
                'Open',
                d['openInput'],
                d['open'],
              ),
              _downloadInput(
                'High',
                d['highInput'],
                d['high'],
              ),
              _downloadInput(
                'Low',
                d['lowInput'],
                d['low'],
              ),
              _downloadInput(
                'Close',
                d['closeInput'],
                d['close'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadInput(
    String title,
    dynamic original,
    dynamic fallback,
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
          _formatInput(
            original,
            fallback,
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _downloadHistorySection({
    required String title,
    required Color color,
    required Color background,
    required Color border,
    required List<List<dynamic>> values,
    required List<List<dynamic>> midpoints,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background.withValues(
          alpha: 0.68,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title == 'RESISTANCE'
                    ? Icons.trending_up
                    : Icons.trending_down,
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
          const SizedBox(height: 8),
          for (int i = 0; i < values.length; i++) ...[
            _downloadHistoryLevel(
              values[i][0].toString(),
              values[i][1],
            ),
            if (showDetail)
              _downloadHistoryMid(
                midpoints[i][0].toString(),
                midpoints[i][1],
              ),
          ],
        ],
      ),
    );
  }

  Widget _downloadHistoryLevel(
    String label,
    dynamic value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _downloadHistoryMid(
    String label,
    dynamic value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1).withValues(
          alpha: 0.92,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: greyText,
            ),
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download() async {
    try {
      final Uint8List image =
          await screenshotController.captureFromLongWidget(
        _buildDownloadWidget(),
        context: context,
        pixelRatio: 3.0,
        delay: const Duration(
          milliseconds: 700,
        ),
        constraints: const BoxConstraints(
          minWidth: 420,
          maxWidth: 420,
        ),
      );

      final hasAccess = await Gal.hasAccess(
        toAlbum: true,
      );

      if (!hasAccess) {
        final granted = await Gal.requestAccess(
          toAlbum: true,
        );

        if (!granted) {
          throw Exception(
            'Izin galeri tidak diberikan.',
          );
        }
      }

      await Gal.putImageBytes(
        image,
        album: 'EWF Hangseng',
        name:
            'hangseng_history_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil Hangseng berhasil disimpan ke galeri',
          ),
          backgroundColor: orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

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

  Future<void> _deleteHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(
          'history_data',
        ) ??
        [];

    if (widget.index >= 0 &&
        widget.index < data.length) {
      data.removeAt(widget.index);

      await prefs.setStringList(
        'history_data',
        data,
      );
    }

    if (!mounted) return;

    Navigator.pop(
      context,
      {'deleted': true},
    );
  }
}