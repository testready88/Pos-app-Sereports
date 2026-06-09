import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';

class SalesRepo {
  // Get sales summary details
  Future<Map<String, dynamic>> getSalesSummary({
    required int page,
    required int size,
    String locaCode = 'All',
    String searchCustomer = '',
    String paymentType = 'All',
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
        url: Api.getSalesSummary, // Add this to your Api class
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          'locaCode': locaCode,
          if (searchCustomer.isNotEmpty) 'searchCustomer': searchCustomer,
          'paymentType': paymentType,
          if (formattedDateFrom.isNotEmpty) 'dateFrom': formattedDateFrom,
          if (formattedDateTo.isNotEmpty) 'dateTo': formattedDateTo,
        },
      );

      // Debugging to see the response structure
      print('Sales API response structure: ${response.keys}');
      if (response['data'] != null) {
        print('Data keys: ${(response['data'] as Map).keys}');
      }

      // Handle case where data might be null
      if (response['data'] == null) {
        return {
          'data': [],
          'count': 0,
          'totalQtySold': 0.0,
          'grossSales': 0.0,
          'itemDiscount': 0.0,
          'netSales': 0.0,
          'profitBeforeDiscount': 0.0,
          'profitAfterDiscount': 0.0,
          'costSales': 0.0,
          'exCharges': 0.0,
          'advancePayment': 0.0,
          'chqPayment': 0.0,
          'cardPayment': 0.0,
          'creditPayment': 0.0,
          'cashPayment': 0.0,
          'creditSettlement': 0.0,
          'cashDiscount': 0.0,
          'pointsRedeem': 0.0,
          'voucherPaid': 0.0,
          'cashSales': 0.0,
          'profitByCashSales': 0.0,
          'creditSales': 0.0,
          'profitByCreditSales': 0.0,
        };
      }

      // Parse the response using the correct field names
      final responseData = response['data'] as Map<String, dynamic>;

      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'totalQtySold': responseData['totalQtySold'] ?? 0.0,
        'grossSales': responseData['grossSales'] ?? 0.0,
        'itemDiscount': responseData['itemDiscount'] ?? 0.0,
        'netSales': responseData['netSales'] ?? 0.0,
        'profitBeforeDiscount': responseData['profitBeforeDiscount'] ?? 0.0,
        'profitAfterDiscount': responseData['profitAfterDiscount'] ?? 0.0,
        'costSales': responseData['costSales'] ?? 0.0,
        'exCharges': responseData['exCharges'] ?? 0.0,
        'advancePayment': responseData['advancePayment'] ?? 0.0,
        'chqPayment': responseData['chqPayment'] ?? 0.0,
        'cardPayment': responseData['cardPayment'] ?? 0.0,
        'creditPayment': responseData['creditPayment'] ?? 0.0,
        'cashPayment': responseData['cashPayment'] ?? 0.0,
        'creditSettlement': responseData['creditSettlement'] ?? 0.0,
        'cashDiscount': responseData['cashDiscount'] ?? 0.0,
        'pointsRedeem': responseData['pointsRedeem'] ?? 0.0,
        'voucherPaid': responseData['voucherPaid'] ?? 0.0,
        'cashSales': responseData['cashSales'] ?? 0.0,
        'profitByCashSales': responseData['profitByCashSales'] ?? 0.0,
        'creditSales': responseData['creditSales'] ?? 0.0,
        'profitByCreditSales': responseData['profitByCreditSales'] ?? 0.0,
      };
    } catch (e, stackTrace) {
      print('Error in getSalesSummary: $e');
      print('Stack trace: $stackTrace');
      throw ApiException(e.toString());
    }
  }

// Get sales details
  Future<Map<String, dynamic>> getSalesDetails({
    required int page,
    required int size,
    String locaCode = 'All',
    String searchItem = '',
    String searchCategory = '',
    String searchSupplier = '',
    String salesType = 'All',
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
        url: Api.getSalesDetails, // Add this to your Api class
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          'locaCode': locaCode,
          if (searchItem.isNotEmpty) 'searchItem': searchItem,
          if (searchCategory.isNotEmpty) 'searchCategory': searchCategory,
          if (searchSupplier.isNotEmpty) 'searchSupplier': searchSupplier,
          'salesType': salesType,
          if (formattedDateFrom.isNotEmpty) 'dateFrom': formattedDateFrom,
          if (formattedDateTo.isNotEmpty) 'dateTo': formattedDateTo,
        },
      );

      // Debugging to see the response structure
      print('Sales Details API response structure: ${response.keys}');
      if (response['data'] != null) {
        print('Data keys: ${(response['data'] as Map).keys}');
      }

      // Handle case where data might be null
      if (response['data'] == null) {
        return {
          'data': [],
          'count': 0,
          'totalQtySold': 0.0,
          'grossSales': 0.0,
          'itemDiscount': 0.0,
          'netSales': 0.0,
          'profitBeforeDiscount': 0.0,
          'profitAfterDiscount': 0.0,
          'costSales': 0.0,
          'exCharges': 0.0,
          'advancePayment': 0.0,
          'chqPayment': 0.0,
          'cardPayment': 0.0,
          'creditPayment': 0.0,
          'cashPayment': 0.0,
          'creditSettlement': 0.0,
          'cashDiscount': 0.0,
          'pointsRedeem': 0.0,
          'voucherPaid': 0.0,
          'cashSales': 0.0,
          'profitByCashSales': 0.0,
          'creditSales': 0.0,
          'profitByCreditSales': 0.0,
        };
      }

      // Parse the response using the correct field names
      final responseData = response['data'] as Map<String, dynamic>;

      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'totalQtySold': responseData['totalQtySold'] ?? 0.0,
        'grossSales': responseData['grossSales'] ?? 0.0,
        'itemDiscount': responseData['itemDiscount'] ?? 0.0,
        'netSales': responseData['netSales'] ?? 0.0,
        'profitBeforeDiscount': responseData['profitBeforeDiscount'] ?? 0.0,
        'profitAfterDiscount': responseData['profitAfterDiscount'] ?? 0.0,
        'costSales': responseData['costSales'] ?? 0.0,
        'exCharges': responseData['exCharges'] ?? 0.0,
        'advancePayment': responseData['advancePayment'] ?? 0.0,
        'chqPayment': responseData['chqPayment'] ?? 0.0,
        'cardPayment': responseData['cardPayment'] ?? 0.0,
        'creditPayment': responseData['creditPayment'] ?? 0.0,
        'cashPayment': responseData['cashPayment'] ?? 0.0,
        'creditSettlement': responseData['creditSettlement'] ?? 0.0,
        'cashDiscount': responseData['cashDiscount'] ?? 0.0,
        'pointsRedeem': responseData['pointsRedeem'] ?? 0.0,
        'voucherPaid': responseData['voucherPaid'] ?? 0.0,
        'cashSales': responseData['cashSales'] ?? 0.0,
        'profitByCashSales': responseData['profitByCashSales'] ?? 0.0,
        'creditSales': responseData['creditSales'] ?? 0.0,
        'profitByCreditSales': responseData['profitByCreditSales'] ?? 0.0,
      };
    } catch (e, stackTrace) {
      print('Error in getSalesDetails: $e');
      print('Stack trace: $stackTrace');
      throw ApiException(e.toString());
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
