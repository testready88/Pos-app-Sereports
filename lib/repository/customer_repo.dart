import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';

// Get customer details
class CustomerRepo {
  // Get customer details
  Future<Map<String, dynamic>> getCustomerDetails({
    required int page,
    required int size,
    String searchText = '',
    String invGap = 'All',
    bool filterCreditAmount = false,
    String settlement = 'All',
  }) async {
    try {
      final response = await Api.get(
        url: Api.getCustomerDetails,
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          if (searchText.isNotEmpty) 'searchText': searchText,
          'invGap': invGap,
          'filterCreditAmount': filterCreditAmount.toString(),
          'settlement': settlement,
        },
      );

      // Handle case where data might be null
      if (response['data'] == null) {
        return {'data': [], 'count': 0, 'totalReceivableAmount': 0.0};
      }

      // Parse the response using the correct field names
      final responseData = response['data'] as Map<String, dynamic>;
      print("=======customer========");
      print(responseData['data']);
      print("=======customer========");
      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'totalReceivableAmount': responseData['totalOutstandingAmount'] ?? 0.0
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getCustomerDebitors({
    required int page,
    required int size,
    String searchText = '',
    String invGap = 'All',
    String creditAmount = '',
    String settlement = 'All',
  }) async {
    try {
      final response = await Api.get(
        url: Api.getCustomerDebitors, // Make sure this is the correct endpoint
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          if (searchText.isNotEmpty) 'searchText': searchText,
          if (creditAmount.isNotEmpty) 'creditAmount': creditAmount,
          'invGap': invGap,
          'settlement': settlement,
        },
      );

      final data = response['data'] ?? {};

      final List<dynamic> contentList = data['content'] ?? data['data'] ?? [];

      final totalElements = data['totalElements'] ?? data['count'] ?? 0;

      final totalAmount = data['totalAmount'] ??
          data['totalOutstandingAmount'] ??
          data['totalReceivableAmount'] ??
          0.0;

      return {
        'data': contentList,
        'totalElements': totalElements,
        'totalAmount': totalAmount,
      };
    } catch (e, stackTrace) {
      print('Error in getCustomerDebitors: $e');
      print('Stack trace: $stackTrace');
      // Return empty data instead of throwing, to prevent UI from freezing
      return {'data': [], 'totalElements': 0, 'totalAmount': 0.0};
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Get customer receivable details
  Future<Map<String, dynamic>> getReceivableDetails({
    required int page,
    required int size,
    String searchCustomer = '',
    String searchInvoice = '',
    String locaCode = 'All',
    String invGap = 'All',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Use current date as default if not provided
      final now = DateTime.now();
      final formattedDateFrom = _formatDateForApi(
          dateFrom ?? now.subtract(const Duration(days: 365)));
      final formattedDateTo = _formatDateForApi(dateTo ?? now);

      final response = await Api.get(
        url: Api.getCustomerRecivables,
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          if (searchCustomer.isNotEmpty) 'searchCustomer': searchCustomer,
          if (searchInvoice.isNotEmpty) 'searchInvoice': searchInvoice,
          'locaCode': locaCode,
          'invGap': invGap,
          if (formattedDateFrom.isNotEmpty) 'dateFrom': formattedDateFrom,
          if (formattedDateTo.isNotEmpty) 'dateTo': formattedDateTo,
        },
      );

      final data = response['data'] ?? {};

      // Directly extract the content array - it might be called 'content'
      // instead of 'data' in your API response
      final List<dynamic> contentList = data['content'] ?? data['data'] ?? [];

      // Extract pagination info and total amount
      final totalElements = data['totalElements'] ?? data['count'] ?? 0;
      // Try different possible field names for the total amount
      final totalAmount = data['totalAmount'] ??
          data['totalOutstandingAmount'] ??
          data['totalReceivableAmount'] ??
          0.0;

      return {
        'data': contentList,
        'totalElements': totalElements,
        'totalAmount': totalAmount,
      };
    } catch (e, stackTrace) {
      print('Error in getCustomerDebitors: $e');
      print('Stack trace: $stackTrace');
      // Return empty data instead of throwing, to prevent UI from freezing
      return {'data': [], 'totalElements': 0, 'totalAmount': 0.0};
    }
  }
}
