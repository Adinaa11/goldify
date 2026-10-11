import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsRepository {
  Future<List<NewsModel>> getMarketNews() async {
    final List<Map<String, dynamic>> data =
        await NewsService.getMarketNews();

    return data
        .map((item) => NewsModel.fromJson(item))
        .toList();
  }
}