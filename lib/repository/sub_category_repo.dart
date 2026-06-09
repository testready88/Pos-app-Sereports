import 'package:sereports/utils/api.dart';

class SubCategoryRepo {
  Future<List<dynamic>> getSubcategorNameList({
    final String? categoryId,
    required final String searchText,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.searchText: searchText,
        Api.categoryId: categoryId,
      };

      final response =
          await Api.get(url: Api.getSubCategoryNameList, parameter: parameter);

      List<dynamic> dataList = (response['data']);

      return dataList;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
