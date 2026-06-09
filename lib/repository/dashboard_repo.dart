import 'package:sereports/utils/api.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboardSummary({
    required String dateFrom,
    required String dateTo,
    required String locationCode,
  }) async {
    try {
      final response = await Api.get(
        url: Api.dashboardSummary,
        parameter: {
          'dateFrom': dateFrom,
          'dateTo': dateTo,
          'locationCode': locationCode,
        },
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      print(e);
      throw ApiException(e.toString());
    }
  }
}
