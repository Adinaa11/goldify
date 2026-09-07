import 'package:flutter/material.dart';
import '../services/market_service.dart';

class HistoricalDataPage extends StatefulWidget {
  const HistoricalDataPage({super.key});

  @override
  State<HistoricalDataPage> createState() =>
      _HistoricalDataPageState();
}

class _HistoricalDataPageState
    extends State<HistoricalDataPage> {
  late Future<List<Map<String, dynamic>>>
      _historicalFuture;

  DateTime? _startDate;
  DateTime? _endDate;

  String _selectedCategory = 'LGD Daily';

  int _currentPage = 1;

  static const int _itemsPerPage = 10;

  final List<String> _categories = [
    'LGD Daily',
    'SNI — Nikkei Jepang',
    'HSI — Hang Seng Hong Kong',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    setState(() {
      _currentPage = 1;

      _historicalFuture =
          MarketService.getHistoricalMarketData(
        category: _selectedCategory,
        startDate: _formatDateForApi(
          _startDate,
        ),
        endDate: _formatDateForApi(
          _endDate,
        ),
      );
    });

    try {
      await _historicalFuture;
    } catch (_) {}
  }

  String? _formatDateForApi(
    DateTime? date,
  ) {
    if (date == null) {
      return null;
    }

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(
    DateTime? date,
  ) {
    if (date == null) {
      return 'dd/mm/yyyy';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectStartDate() async {
    final DateTime? selected =
        await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _startDate = selected;

      if (_endDate != null &&
          _endDate!.isBefore(selected)) {
        _endDate = null;
      }
    });

    await _loadHistoricalData();
  }

  Future<void> _selectEndDate() async {
    final DateTime? selected =
        await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
              _startDate ??
              DateTime.now(),
      firstDate:
          _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _endDate = selected;
    });

    await _loadHistoricalData();
  }

  Future<void> _changeCategory(
    String? value,
  ) async {
    if (value == null ||
        value == _selectedCategory) {
      return;
    }

    setState(() {
      _selectedCategory = value;
      _currentPage = 1;
    });

    await _loadHistoricalData();
  }

  String _getCategorySubtitle() {
    switch (_selectedCategory) {
      case 'SNI — Nikkei Jepang':
        return 'Indeks Nikkei Jepang';

      case 'HSI — Hang Seng Hong Kong':
        return 'Indeks Hang Seng Hong Kong';

      default:
        return 'Harga emas LGD Daily';
    }
  }

  String _getValue(
    Map<String, dynamic> item,
    String key,
  ) {
    final dynamic value = item[key];

    if (value == null) {
      return '-';
    }

    if (value.toString().trim().isEmpty) {
      return '-';
    }

    return value.toString();
  }

  int _totalPages(
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) {
      return 1;
    }

    return (data.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> _getPageData(
    List<Map<String, dynamic>> data,
  ) {
    final int start =
        (_currentPage - 1) * _itemsPerPage;

    if (start >= data.length) {
      return [];
    }

    final int end =
        (start + _itemsPerPage)
            .clamp(0, data.length);

    return data.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
          ),
          color: const Color(0xFF555555),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Historical Data Emas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ),
      body: FutureBuilder<
          List<Map<String, dynamic>>>(
        future: _historicalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEFAE21),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildError(
              snapshot.error,
            );
          }

          final List<Map<String, dynamic>> data =
              snapshot.data ?? [];

          return RefreshIndicator(
            color: const Color(0xFFEFAE21),
            onRefresh: () async {
              await _loadHistoricalData();
            },
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              children: [
                _buildIntroCard(),
                const SizedBox(height: 14),
                _buildFilterCard(),
                const SizedBox(height: 14),
                _buildHistoricalTable(data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5DA),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: Color(0xFFD99100),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Historis Market',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Lihat pergerakan harga '
                  '$_selectedCategory '
                  'berdasarkan periode yang dipilih.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'FILTER DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 9),
          _buildCategoryDropdown(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  title: 'Tanggal Awal',
                  value:
                      _formatDateDisplay(
                    _startDate,
                  ),
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateField(
                  title: 'Tanggal Akhir',
                  value:
                      _formatDateDisplay(
                    _endDate,
                  ),
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed:
                  _loadHistoricalData,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFEFAE21),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 19,
              ),
              label: const Text(
                'Tampilkan Data',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'KATEGORI',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF2),
            borderRadius:
                BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFF0D28A),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFD88D00),
              ),
              dropdownColor: Colors.white,
              borderRadius:
                  BorderRadius.circular(10),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
              items: _categories
                  .map(
                    (String category) {
                  return DropdownMenuItem<
                      String>(
                    value: category,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Color(
                            0xFFD88D00,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            category,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              onChanged:
                  _changeCategory,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _getCategorySubtitle(),
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final bool hasDate =
        value != 'dd/mm/yyyy';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE4E4E4),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(0xFF999999),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: hasDate
                          ? const Color(
                              0xFF333333,
                            )
                          : const Color(
                              0xFFAAAAAA,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalTable(
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEDEDED),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 42,
              color: Color(0xFFBBBBBB),
            ),
            SizedBox(height: 10),
            Text(
              'Tidak ada data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555555),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Data tidak tersedia untuk filter yang dipilih.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    final List<Map<String, dynamic>> pageData =
        _getPageData(data);

    final int totalPages = _totalPages(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        14,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Data Historis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              Text(
                '${data.length} data',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: double.infinity,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.8),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                defaultVerticalAlignment:
                    TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8E8),
                    ),
                    children: [
                      _buildTableHeader(
                        'Tanggal',
                        alignment: Alignment.centerLeft,
                      ),
                      _buildTableHeader('Open'),
                      _buildTableHeader('High'),
                      _buildTableHeader('Low'),
                      _buildTableHeader('Close'),
                    ],
                  ),
                  ...pageData.map(
                    (item) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE2E2E2),
                            ),
                          ),
                        ),
                        children: [
                          _buildTableCell(
                            _formatTableDate(
                              _getValue(
                                item,
                                'tanggal',
                              ),
                            ),
                            alignment:
                                Alignment.centerLeft,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          _buildTableCell(
                            _getValue(
                              item,
                              'open',
                            ),
                          ),
                          _buildTableCell(
                            _getValue(
                              item,
                              'high',
                            ),
                          ),
                          _buildTableCell(
                            _getValue(
                              item,
                              'low',
                            ),
                          ),
                          _buildTableCell(
                            _getValue(
                              item,
                              'close',
                            ),
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    String text, {
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      height: 46,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Text(
        text,
        textAlign:
            alignment == Alignment.center
                ? TextAlign.center
                : TextAlign.left,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    Alignment alignment = Alignment.center,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Container(
      height: 58,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign:
            alignment == Alignment.center
                ? TextAlign.center
                : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: fontWeight,
          color: const Color(0xFF444444),
        ),
      ),
    );
  }

  String _formatTableDate(
    String value,
  ) {
    if (value == '-') {
      return '-';
    }

    try {
      final DateTime date =
          DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  Widget _buildPagination(
    int totalPages,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
          icon: const Icon(
            Icons.chevron_left_rounded,
          ),
          color: const Color(
            0xFFD99100,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFFFFF5DA,
            ),
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Text(
            '$_currentPage / $totalPages',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD88D00),
            ),
          ),
        ),
        IconButton(
          onPressed:
              _currentPage < totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
          icon: const Icon(
            Icons.chevron_right_rounded,
          ),
          color: const Color(
            0xFFD99100,
          ),
        ),
      ],
    );
  }

  Widget _buildError(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: const Color(
                0xFFEDEDED,
              ),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFD9534F),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                error
                        ?.toString()
                        .replaceFirst(
                          'Exception: ',
                          '',
                        ) ??
                    'Terjadi kesalahan.',
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed:
                      _loadHistoricalData,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFEFAE21,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}