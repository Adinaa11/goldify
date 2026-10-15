import '../models/historical_data_model.dart';
import '../services/market_service.dart';

class HistoricalDataRepository {
  Future<List<HistoricalDataModel>> getHistoricalData({
    required String category,
    String? startDate,
    String? endDate,
  }) async {
    final response =
        await MarketService.getHistoricalMarketData(
      category: category,
      startDate: startDate,
      endDate: endDate,
    );

    return response
        .map(
          (item) => HistoricalDataModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}