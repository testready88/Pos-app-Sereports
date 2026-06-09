import 'package:intl/intl.dart';

import 'package:sereports/utils/api.dart';

class BankRepository {
  // Get all bank names
  Future<List<String>> getAllBankNames() async {
    try {
      final response = await Api.get(
        url: Api
            .getBankNameList, // This should be defined in your Api class as '/get-all-bank-names'
        parameter: {},
      );

      // Debug the full response

      // Extract data from response
      final data = response['data'];

      if (data == null) {
        return [];
      }

      if (data is List) {
        final bankNames = data.map((item) => item.toString()).toList();
        return bankNames;
      }

      // Fallback
      print('Unexpected data type for bank names, not a list');
      return [];
    } catch (e, stackTrace) {
      print('Error in getAllBankNames: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load bank names: $e');
    }
  }

  // Get bank details
  Future<Map<String, dynamic>> getBankDetails({
    required String bankName,
    required String locationCode,
    required String dateTo,
  }) async {
    try {
      final params = {
        'bankName': bankName,
        'locationCode': locationCode,
        'dateTo': dateTo,
      };

      final response = await Api.get(
        url: Api.getBankDetails, // Should be defined as '/get-all-bank-details'
        parameter: params,
      );

      // Debug the full response

      if (response['code'] != 200) {
        throw Exception('API error: ${response['message']}');
      }

      final data = response['data'];
      if (data == null) {
        throw Exception('Bank details data is null');
      }

      return data;
    } catch (e, stackTrace) {
      print('Error in getBankDetails: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load bank details: $e');
    }
  }

  Future<Map<String, dynamic>> getBankTransactions({
    required int page,
    required int size,
    String locaCode = 'All',
    String bankName = 'All',
    String searchText = '',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Use current date as default if not provided

      Map<String, dynamic> parameters = {
        'page': page.toString(),
        'size': size.toString(),
        'locaCode': locaCode,
        'bankName': bankName,
        'searchText': searchText,
      };

      // Format dates to string if they exist, otherwise send empty string
      if (dateFrom != null) {
        parameters['dateFrom'] = DateFormat('yyyy-MM-dd').format(dateFrom);
      } else {
        parameters['dateFrom'] = ''; // Send empty string instead of null
      }

      if (dateTo != null) {
        parameters['dateTo'] = DateFormat('yyyy-MM-dd').format(dateTo);
      } else {
        parameters['dateTo'] = ''; // Send empty string instead of null
      }

      final response = await Api.get(
        url: Api.getBankTransactions,
        parameter: parameters,
      );

      final data = response['data'] ?? {};

      final List<dynamic> transactions = data['content'] ?? data['data'] ?? [];
      final totalElements = data['count'] ?? 0;

      final totalAmount = data['bankBalance'] ?? 0.0;

      return {
        'data': transactions,
        'totalElements': totalElements,
        'totalAmount': totalAmount,
      };
    } catch (e, stackTrace) {
      print('Error in getBankTransactions: $e');
      print('Stack trace: $stackTrace');
      return {'data': [], 'totalElements': 0, 'totalAmount': 0.0};
    }
  }
}
