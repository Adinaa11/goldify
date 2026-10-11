
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../viewmodels/news_viewmodel.dart';

class NewsSection extends StatefulWidget {
  final VoidCallback onSeeAllTap;

  const NewsSection({
    super.key,
    required this.onSeeAllTap,
  });

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  late final NewsViewModel _viewModel;

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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan artikel tidak tersedia.'),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel tidak dapat dibuka.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka artikel.'),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Berita pasar';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  Widget _buildThumbnail(String? imageUrl) {
    Widget fallback() {
      return Container(
        height: 85,
        width: double.infinity,
        color: const Color(0xFFFFF3E0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.candlestick_chart_rounded,
          size: 34,
          color: Color(0xFFF7931E),
        ),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return fallback();
    }

    return Image.network(
      imageUrl,
      height: 85,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = _viewModel.news.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Market News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252525),
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onSeeAllTap,
              child: const Text('Lihat Selengkapnya'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_viewModel.isLoading && news.isEmpty)
          const SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_viewModel.errorMessage != null && news.isEmpty)
          SizedBox(
            height: 145,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Berita belum dapat dimuat.'),
                  TextButton(
                    onPressed: _viewModel.loadNews,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          )
        else if (news.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text('Belum ada berita terbaru.'),
            ),
          )
        else
          SizedBox(
            height: 225,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: news.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final NewsModel item = news[index];

                return SizedBox(
                  width: 235,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    elevation: 1,
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _openArticle(item.link),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildThumbnail(item.imageUrl),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              10, 9, 10, 8,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.source,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF7931E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF252525),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(item.publishedAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}