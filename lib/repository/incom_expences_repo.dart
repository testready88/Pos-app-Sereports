import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';

class IncomeExpencesRepo {
  Future<Map<String, dynamic>> getIncomeExpensesDetails({
    required int page,
    required int size,
    String locaCode = 'All',
    String searchDescription = '',
    String searchVendor = '',
    String invType = 'All',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Use current date as default if not provided
      final parameters = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'locaCode': locaCode,
        'searchDescription': searchDescription,
        'searchVendor': searchVendor,
        'invType': invType,
        'dateFrom': dateFrom != null ? _formatDateForApi(dateFrom) : '',
        'dateTo': dateTo != null ? _formatDateForApi(dateTo) : '',
      };

      final response = await Api.get(
        url: Api.getIncomeExpensesDetails, // Add this to your Api class
        parameter: parameters,
      );

      if (response['data'] != null) {
        print('Data keys: ${(response['data'] as Map).keys}');
      }

      if (response['data'] == null) {
        return {
          'data': [],
          'count': 0,
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'netAmount': 0.0,
        };
      }

      // Parse the response using the correct field names
      final responseData = response['data'] as Map<String, dynamic>;

      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'netIncome': responseData['netIncome'] ?? 0.0,
        'netExpenses': responseData['netExpenses'] ?? 0.0,
        'netAmount': (responseData['netIncome'] ?? 0.0) -
            (responseData['netExpenses'] ?? 0.0),
      };
    } catch (e, stackTrace) {
      print('Error in getIncomeExpensesDetails: $e');
      print('Stack trace: $stackTrace');
      throw ApiException(e.toString());
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
