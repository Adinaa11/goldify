
class NewsModel {
  final String title;
  final String summary;
  final String link;
  final String source;
  final String? imageUrl;
  final DateTime? publishedAt;

  const NewsModel({
    required this.title,
    required this.summary,
    required this.link,
    required this.source,
    this.imageUrl,
    this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title']?.toString() ?? 'Tanpa judul',
      summary: json['summary']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      source: json['source']?.toString() ??
          'Sumber tidak diketahui',
      imageUrl: _parseImageUrl(json['imageUrl']),
      publishedAt: DateTime.tryParse(
        json['publishedAt']?.toString() ?? '',
      ),
    );
  }

  static String? _parseImageUrl(dynamic value) {
    if (value == null) return null;

    final url = value.toString().trim();

    if (url.isEmpty ||
        !(url.startsWith('https://') ||
            url.startsWith('http://'))) {
      return null;
    }

    return url;
  }
}