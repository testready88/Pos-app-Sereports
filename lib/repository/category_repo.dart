import 'package:sereports/utils/api.dart';

class CategoryRepo {
  Future<List<dynamic>> getCategoryNameList(
      {required final String searchText}) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.searchText: searchText,
      };

      final response =
          await Api.get(url: Api.getCategoryNameList, parameter: parameter);

      List<dynamic> dataList = (response['data']);
      return dataList;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
