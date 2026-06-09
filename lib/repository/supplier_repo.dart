// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';

class SupplierRepo {
  String _formatApiDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<List<dynamic>> getSupplierNameList(
      {required final String searchText}) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.searchText: searchText,
      };

      final response =
          await Api.get(url: Api.getSupplierNameList, parameter: parameter);

      List<dynamic> dataList = (response['data']);

      return dataList;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getSupplierDetails({
    required int page,
    required int size,
    String supplierSearch = '',
    String creditSearch = '',
    String invGap = 'All',
    String settlementGap = 'All',
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'invGap': invGap,
        'settlementGap': settlementGap,
      };

      // Only add these params if they're not empty
      if (supplierSearch.isNotEmpty) {
        queryParams['supplierSearch'] = supplierSearch;
      }

      if (creditSearch.isNotEmpty) {
        queryParams['creditSearch'] = creditSearch;
      }

      final response = await Api.get(
        url: Api.getSupplierDetails,
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          if (supplierSearch.isNotEmpty) 'supplierSearch': supplierSearch,
          if (creditSearch.isNotEmpty) 'creditSearch': creditSearch,
          'invGap': invGap,
          'settlementGap': settlementGap,
        },
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      print(e);
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getCreditorDetailsList({
    required int page,
    required int size,
    String supplierSearch = '',
    String creditSearch = '',
    String invGap = 'All',
    String settlementGap = 'All',
  }) async {
    try {
      final response = await Api.get(
        url: Api.getCreditorDetailsList,
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          if (supplierSearch.isNotEmpty) 'supplierSearch': supplierSearch,
          if (creditSearch.isNotEmpty) 'creditSearch': creditSearch,
          'invGap': invGap,
          'settlementGap': settlementGap,
        },
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      print(e);
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getPayableDetails({
    required int page,
    required int size,
    String locaCode = 'All',
    String searchSupplier = '',
    String searchInvoice = '',
    String invGap = 'All',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getSupplierPayableList,
        parameter: {
          'page': page.toString(),
          'size': size.toString(),
          'locaCode': locaCode,
          if (searchSupplier.isNotEmpty) 'searchSupplier': searchSupplier,
          if (searchInvoice.isNotEmpty) 'searchInvoice': searchInvoice,
          'invGap': invGap,
          if (dateFrom != null) 'dateFrom': _formatApiDate(dateFrom),
          if (dateTo != null) 'dateTo': _formatApiDate(dateTo),
        },
      );

      print(response['data']['totalOutstandingAmount']);
      return response;
    } catch (e) {
      print(e);
      throw ApiException(e.toString());
    }
  }
}
