import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';

class PurchaseRepo {
  Future<Map<String, dynamic>> getPurchaseDetails({
    required int page,
    required int size,
    String locaCode = 'All',
    String searchItem = '',
    String searchCategory = '',
    String searchSupplier = '',
    String purchaseType = 'All',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final parameters = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'locaCode': locaCode,
        'searchItem': searchItem,
        'searchCategory': searchCategory,
        'searchSupplier': searchSupplier,
        'purchaseType': purchaseType,
        'dateFrom': dateFrom != null ? _formatDateForApi(dateFrom) : '',
        'dateTo': dateTo != null ? _formatDateForApi(dateTo) : '',
      };
      final response = await Api.get(
          url: Api.getPurchaseDetails, // Add this to your Api class
          parameter: parameters);

      // Debugging to see the response structure
      print('Purchase Details API response structure: ${response.keys}');
      if (response['data'] != null) {
        print('Data keys: ${(response['data'] as Map).keys}');
      }

      // Handle case where data might be null
      if (response['data'] == null) {
        return {
          'data': [],
          'count': 0,
          'totalQtyPur': 0.0,
          'grossPurchase': 0.0,
          'itemDiscountPur': 0.0,
          'netPurchase': 0.0,
          'cashDiscountPur': 0.0,
          'advancePaymentPur': 0.0,
          'chqPaymentPur': 0.0,
          'cardPaymentPur': 0.0,
          'creditPaymentPur': 0.0,
          'cashPaymentPur': 0.0,
          'transportCharge': 0.0,
          'labourCharge': 0.0,
        };
      }

      // Parse the response using the correct field names
      final responseData = response['data'] as Map<String, dynamic>;

      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'totalQtyPur': responseData['totalQtyPur'] ?? 0.0,
        'grossPurchase': responseData['grossPurchase'] ?? 0.0,
        'itemDiscountPur': responseData['itemDiscountPur'] ?? 0.0,
        'netPurchase': responseData['netPurchase'] ?? 0.0,
        'cashDiscountPur': responseData['cashDiscountPur'] ?? 0.0,
        'advancePaymentPur': responseData['advancePaymentPur'] ?? 0.0,
        'chqPaymentPur': responseData['chqPaymentPur'] ?? 0.0,
        'cardPaymentPur': responseData['cardPaymentPur'] ?? 0.0,
        'creditPaymentPur': responseData['creditPaymentPur'] ?? 0.0,
        'cashPaymentPur': responseData['cashPaymentPur'] ?? 0.0,
        'transportCharge': responseData['transportCharge'] ?? 0.0,
        'labourCharge': responseData['labourCharge'] ?? 0.0,
      };
    } catch (e, stackTrace) {
      print('Error in getPurchaseDetails: $e');
      print('Stack trace: $stackTrace');
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getPurchaseSummary({
    required int page,
    required int size,
    String? locaCode,
    String? searchSupplier,
    String? searchInvoice,
    String? paymentType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Only include parameters that have actual values
      final parameters = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'locaCode': locaCode ?? 'All',
        'searchSupplier': searchSupplier ?? '',
        'searchInvoice': searchInvoice ?? '',
        'paymentType': paymentType ?? 'All',
        'dateFrom': dateFrom != null ? _formatDateForApi(dateFrom) : '',
        'dateTo': dateTo != null ? _formatDateForApi(dateTo) : '',
      };

      // // Only add optional parameters if they have meaningful values
      // if (locaCode != null && locaCode.isNotEmpty && locaCode != 'All') {
      //   parameters['locaCode'] = locaCode;
      // }

      // if (searchSupplier != null && searchSupplier.isNotEmpty) {
      //   parameters['searchSupplier'] = searchSupplier;
      // }

      // if (searchInvoice != null && searchInvoice.isNotEmpty) {
      //   parameters['searchInvoice'] = searchInvoice;
      // }

      // if (paymentType != null &&
      //     paymentType.isNotEmpty &&
      //     paymentType != 'All') {
      //   parameters['paymentType'] = paymentType;
      // }

      // if (dateFrom != null) {
      //   parameters['dateFrom'] = DateFormat('yyyy-MM-dd').format(dateFrom);
      // }

      // if (dateTo != null) {
      //   parameters['dateTo'] = DateFormat('yyyy-MM-dd').format(dateTo);
      // }

      // Debug log - only shows what's actually being sent
      print('API Call: ${Api.getPurchaseSummary}');
      print('Parameters: $parameters');

      final response = await Api.get(
        url: Api.getPurchaseSummary,
        parameter: parameters,
      );

      if (response['data'] == null) {
        return {
          'data': [],
          'count': 0,
          'totalQtyPur': 0.0,
          'grossPurchase': 0.0,
          'itemDiscountPur': 0.0,
          'netPurchase': 0.0,
          'cashDiscountPur': 0.0,
          'advancePaymentPur': 0.0,
          'chqPaymentPur': 0.0,
          'cardPaymentPur': 0.0,
          'creditPaymentPur': 0.0,
          'cashPaymentPur': 0.0,
          'transportCharge': 0.0,
          'labourCharge': 0.0,
        };
      }

      final responseData = response['data'] as Map<String, dynamic>;
      return {
        'data': responseData['data'] ?? [],
        'count': responseData['count'] ?? 0,
        'totalQtyPur': responseData['totalQtyPur'] ?? 0.0,
        'grossPurchase': responseData['grossPurchase'] ?? 0.0,
        'itemDiscountPur': responseData['itemDiscountPur'] ?? 0.0,
        'netPurchase': responseData['netPurchase'] ?? 0.0,
        'cashDiscountPur': responseData['cashDiscountPur'] ?? 0.0,
        'advancePaymentPur': responseData['advancePaymentPur'] ?? 0.0,
        'chqPaymentPur': responseData['chqPaymentPur'] ?? 0.0,
        'cardPaymentPur': responseData['cardPaymentPur'] ?? 0.0,
        'creditPaymentPur': responseData['creditPaymentPur'] ?? 0.0,
        'cashPaymentPur': responseData['cashPaymentPur'] ?? 0.0,
        'transportCharge': responseData['transportCharge'] ?? 0.0,
        'labourCharge': responseData['labourCharge'] ?? 0.0,
      };
    } catch (e) {
      print('API Error: $e');
      throw ApiException(e.toString());
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
