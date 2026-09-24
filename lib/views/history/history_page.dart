import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/history_viewmodel.dart';
import '../../models/history_model.dart';

import 'history_detail_pivot.dart';
import 'history_detail_emas.dart';
import 'history_detail_hangseng.dart';
import 'history_detail_nest.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryPage({
    super.key,
    this.onBack,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color orange = Color(0xFFF7931E);
  static const Color background = Color(0xFFF5F6F8);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  void _openDetail(
    HistoryModel model,
  ) {
    final item = model.toHistoryMap();

    final type =
        model.type.toLowerCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (type.contains("pivot")) {
            return HistoryDetailPivotPage(
              item: item,
              index: -1,
            );
          }

          if (type.contains("hangseng") ||
              type.contains("hsi")) {
            return HistoryDetailHangsengPage(
              item: item,
              index: -1,
            );
          }

          if (type.contains("nest")) {
            return HistoryDetailNestPage(
              item: item,
              index: -1,
            );
          }

          return HistoryDetailEmasPage(
            item: item,
            index: -1,
          );
        },
      ),
    ).then((_) {
      if (!mounted) return;

      context
          .read<HistoryViewModel>()
          .loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    final groups = vm.groupedHistory;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: orange,
            size: 21,
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        titleSpacing: 0,
        title: const Text(
          "Daftar Perhitungan Anda",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),

      body: Column(
        children: [

          // FILTER
          _buildFilter(vm),

          // LIST / EMPTY
          Expanded(
            child: vm.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: orange,
                    ),
                  )
                : groups.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        itemCount: groups.fold<int>(
                          0,
                          (
                            total,
                            group,
                          ) =>
                              total +
                              1 +
                              group.value.length,
                        ),
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          int currentIndex = 0;

                          for (final group in groups) {

                            // HEADER TANGGAL
                            if (index == currentIndex) {
                              final date =
                                  group.value.first.createdAt;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 12,
                                  bottom: 4,
                                ),
                                child: Text(
                                  date == null
                                      ? 'LAINNYA'
                                      : vm.dateHeader(date),
                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    color:
                                        Color(0xFF555555),
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              );
                            }

                            currentIndex++;

                            // ITEM
                            if (index <
                                currentIndex +
                                    group.value.length) {
                              final itemIndex =
                                  index - currentIndex;

                              return _buildHistoryCard(
                                group.value[itemIndex],
                                vm,
                              );
                            }

                            currentIndex +=
                                group.value.length;
                          }

                          return const SizedBox.shrink();
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(
    HistoryViewModel vm,
  ) {
    final list = [
      "Semua",
      "Pivot",
      "Hangseng",
      "Emas Fisik",
      "NEST",
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        10,
      ),
      child: Row(
        children: list.map((e) {
          final active =
              vm.selectedFilter == e;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                vm.changeFilter(e);
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? orange
                      : Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    e,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 10,
                      color: active
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.history,
            size: 60,
            color: orange,
          ),
          SizedBox(height: 20),
          Text(
            "Belum Ada Riwayat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    HistoryModel model,
    HistoryViewModel vm,
  ) {
    final resultData =
        model.result;

    final resultText =
        resultData['status']
                ?.toString() ??
            '';

    final amount =
        resultData['step5'] ?? 0;

    final resultColor =
        vm.getResultColor(model);

    final type =
        model.type.toLowerCase();

    final bool pivot =
        type.contains("pivot");

    final bool hangseng =
        type.contains("hangseng") ||
        type.contains("hsi");

    final bool nest =
        type.contains("nest");

    return GestureDetector(
      onTap: () {
        _openDetail(model);
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(
          12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE4E4E4),
          ),
          borderRadius:
              BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF3E0,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Icon(
                    pivot
                        ? Icons
                            .analytics_outlined
                        : hangseng
                            ? Icons.trending_up
                            : nest
                                ? Icons.swap_vert
                                : Icons
                                    .calculate_outlined,
                    color: orange,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        pivot
                            ? "Pivot Point"
                            : hangseng
                                ? "Hangseng"
                                : nest
                                    ? "NEST"
                                    : "Emas Fisik",
                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF222222),
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        vm.formatDateTime(
                          model.createdAt,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              height: 1,
              color:
                  const Color(0xFFE8E8E8),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "Hasil Perhitungan",
              style: TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF777777),
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    pivot
                        ? "Pivot : ${vm.formatPivot(resultData['pivot'] ?? resultData['pp'])}"
                        : hangseng
                            ? "PP : ${vm.formatPivot(resultData['pp'])}"
                            : nest
                                ? "Action : $resultText"
                                : "$resultText : Rp ${vm.formatRupiah(amount)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          resultColor,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color:
                      Color(0xFF777777),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}