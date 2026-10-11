
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../viewmodels/news_viewmodel.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsViewModel _viewModel;

  static const Color _orange = Color(0xFFF7931E);
  static const Color _dark = Color(0xFF252525);

  @override
  void initState() {
    super.initState();
    _viewModel = NewsViewModel();
    _viewModel.addListener(_onNewsChanged);
    _viewModel.loadNews();
  }

  void _onNewsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onNewsChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openArticle(String link) async {
    final uri = Uri.tryParse(link);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showMessage('Tautan artikel tidak tersedia.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage('Artikel tidak dapat dibuka.');
      }
    } catch (_) {
      if (mounted) _showMessage('Gagal membuka artikel.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  String _filterLabel(NewsFilter filter) {
    switch (filter) {
      case NewsFilter.terpopuler:
        return 'Terpopuler';
      case NewsFilter.hariIni:
        return 'Hari Ini';
      case NewsFilter.seminggu:
        return 'Seminggu';
      case NewsFilter.sebulan:
        return 'Sebulan';
    }
  }

  Widget _buildThumbnail(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _thumbnailPlaceholder();
    }

    return Image.network(
      imageUrl,
      height: 190,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _thumbnailPlaceholder();
      },
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xFFFFF3E0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.candlestick_chart_rounded,
        size: 52,
        color: _orange,
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: NewsFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = NewsFilter.values[index];
          final selected = _viewModel.selectedFilter == filter;

          return ChoiceChip(
            label: Text(_filterLabel(filter)),
            selected: selected,
            onSelected: (_) => _viewModel.setFilter(filter),
            selectedColor: _orange,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? _orange : Colors.grey.shade300,
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _dark,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsModel item) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _openArticle(item.link),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(item.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.source,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                      color: _dark,
                    ),
                  ),
                  if (item.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _formatDate(item.publishedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Text(
                        'Baca artikel',
                        style: TextStyle(
                          color: _orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: _orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada berita pada periode ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _viewModel.loadNews,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = _viewModel.filteredNews;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Market News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berita dan Perkembangan Pasar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pilih periode berita yang ingin kamu baca.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),
                _buildFilters(),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _viewModel.loadNews,
              child: _viewModel.isLoading && _viewModel.news.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: CircularProgressIndicator()),
                        SizedBox(height: 16),
                        Center(child: Text('Memuat berita pasar...')),
                      ],
                    )
                  : _viewModel.errorMessage != null &&
                          _viewModel.news.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 120),
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 52,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Berita belum dapat dimuat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                _viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _viewModel.loadNews,
                                child: const Text('Coba Lagi'),
                              ),
                            ),
                          ],
                        )
                      : news.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context)
                                          .size
                                          .height *
                                      0.2,
                                ),
                                _buildEmptyState(),
                              ],
                            )
                          : ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: news.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildNewsCard(news[index]);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}