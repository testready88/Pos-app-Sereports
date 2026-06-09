// ignore_for_file: avoid_print

import 'package:sereports/utils/api.dart';

class ProductRepo {
  Future<List<dynamic>> getAllProduct(
      {required final Map<String, dynamic> searchqueryParams}) async {
    try {
      final response =
          await Api.get(url: Api.getProductAll, parameter: searchqueryParams);

      final nestedData = response['data'] as Map<String, dynamic>;
      final dataList = List<dynamic>.from(nestedData['data']);

      return dataList;
    } catch (e) {
      print(e);
      throw ApiException(e.toString());
    }
  }
}
