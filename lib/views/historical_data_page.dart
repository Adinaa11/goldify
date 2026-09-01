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

  int _currentPage = 1;

  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  void _loadHistoricalData() {
    setState(() {
      _currentPage = 1;

      _historicalFuture =
          MarketService.getHistoricalGoldData(
        startDate: _formatDateForApi(_startDate),
        endDate: _formatDateForApi(_endDate),
      );
    });
  }

  String? _formatDateForApi(DateTime? date) {
    if (date == null) {
      return null;
    }

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(DateTime? date) {
    if (date == null) {
      return 'dd/mm/yyyy';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // DATE PICKER
  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;
    });
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

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
            return _buildError(snapshot.error);
          }

          final data = snapshot.data ?? [];

          return RefreshIndicator(
            color: const Color(0xFFEFAE21),
            onRefresh: () async {
              _loadHistoricalData();
              await _historicalFuture;
            },

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D8),
              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: const Icon(
              Icons.show_chart_rounded,
              color: Color(0xFFD88D00),
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Data Historis Emas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF252525),
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Lihat pergerakan harga LGD Daily '
                  'berdasarkan periode yang dipilih.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
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

  //FILTER CARD
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            'Periode Data',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 14),

          // KATEGORI
          const Text(
            'KATEGORI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF777777),
            ),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF0D28A),
              ),
            ),

            child: const Row(
              children: [

                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Color(0xFFD88D00),
                ),

                SizedBox(width: 8),

                Text(
                  'LGD Daily',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [

              Expanded(
                child: _buildDateField(
                  label: 'MULAI',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildDateField(
                  label: 'AKHIR',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,

            child: ElevatedButton.icon(
              onPressed: _loadHistoricalData,

              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),

              label: const Text(
                'Tampilkan Data',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFEFAE21),

                foregroundColor: Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DATE FIELD
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(10),

      child: Container(
        height: 58,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE1E5EA),
          ),
        ),

        child: Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDateDisplay(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: date == null
                          ? const Color(0xFF999999)
                          : const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }

  // TABLE
  Widget _buildHistoricalTable(
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),

        child: const Column(
          children: [

            Icon(
              Icons.bar_chart_outlined,
              size: 38,
              color: Color(0xFFAAAAAA),
            ),

            SizedBox(height: 10),

            Text(
              'Data tidak ditemukan',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final int totalPages =
        (data.length / _itemsPerPage).ceil();

    final int startIndex =
        (_currentPage - 1) * _itemsPerPage;

    final int endIndex =
        (startIndex + _itemsPerPage)
            .clamp(0, data.length);

    final displayedData =
        data.sublist(
      startIndex,
      endIndex,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E8EC),
        ),
      ),

      child: Column(
        children: [

          // HEADER
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 13,
            ),

            decoration: const BoxDecoration(
              color: Color(0xFFFFFBF3),
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),

            child: const Row(
              children: [

                SizedBox(
                  width: 76,
                  child: _HeaderText(
                    'Tanggal',
                  ),
                ),

                Expanded(
                  child: _HeaderText(
                    'Open',
                  ),
                ),

                Expanded(
                  child: _HeaderText(
                    'High',
                  ),
                ),

                Expanded(
                  child: _HeaderText(
                    'Low',
                  ),
                ),

                Expanded(
                  child: _HeaderText(
                    'Close',
                  ),
                ),
              ],
            ),
          ),

          ...displayedData.map(
            (item) => _buildRow(item),
          ),

          _buildPagination(
            totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    Map<String, dynamic> item,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),

      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEDEDED),
          ),
        ),
      ),

      child: Row(
        children: [

          SizedBox(
            width: 76,

            child: Text(
              item['tanggal']
                      ?.toString() ??
                  '-',

              style: const TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
                color: Color(0xFF30343B),
              ),
            ),
          ),

          Expanded(
            child: _value(
              item['open'],
            ),
          ),

          Expanded(
            child: _value(
              item['high'],
            ),
          ),

          Expanded(
            child: _value(
              item['low'],
            ),
          ),

          Expanded(
            child: _value(
              item['close'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _value(dynamic value) {
    return Text(
      value?.toString() ?? '-',
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF505762),
      ),
    );
  }

  // PAGINATION
  Widget _buildPagination(
    int totalPages,
  ) {
    if (totalPages <= 1) {
      return const SizedBox(
        height: 15,
      );
    }

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        15,
        12,
        15,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          _pageButton(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1,

            onTap: () {
              if (_currentPage > 1) {
                setState(() {
                  _currentPage--;
                });
              }
            },
          ),

          const SizedBox(width: 8),

          Container(
            width: 34,
            height: 34,

            alignment:
                Alignment.center,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFEFAE21),
              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Text(
              '$_currentPage',
              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 8),

          _pageButton(
            icon: Icons.chevron_right,
            enabled:
                _currentPage < totalPages,

            onTap: () {
              if (_currentPage <
                  totalPages) {
                setState(() {
                  _currentPage++;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,

      borderRadius:
          BorderRadius.circular(9),

      child: Container(
        width: 34,
        height: 34,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(9),
          border: Border.all(
            color: const Color(0xFFE0E4E9),
          ),
        ),

        child: Icon(
          icon,
          size: 19,
          color: enabled
              ? const Color(0xFF555555)
              : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }

  // ERROR
  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.cloud_off_outlined,
              size: 45,
              color: Color(0xFF999999),
            ),

            const SizedBox(height: 12),

            const Text(
              'Data historis gagal dimuat',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed:
                  _loadHistoricalData,

              child: const Text(
                'Coba Lagi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFFD58A00),
      ),
    );
  }
}