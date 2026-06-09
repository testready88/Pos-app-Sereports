import 'package:sereports/model/dropdown.dart';
import 'package:sereports/utils/api.dart';

class DropdownRepository {
  // Map dropdown types to their respective API endpoints
  final Map<String, String> _endpoints = {
    'supplier': Api.getSupplierNameList,
    'category': Api.getCategoryNameList, // Adjust with your actual endpoint
    'subcategory':
        Api.getSubCategoryNameList, // Adjust with your actual endpoint
    // Add more endpoints as needed
  };

  Future<List<DropdownItem>> getDropdownItems({
    required String dropdownType,
    String searchText = "",
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.searchText: searchText,
      };

      final response = await Api.get(
        url: _endpoints[dropdownType]!,
        parameter: parameter,
      );

      final List<dynamic> dataList = response['data'];

      // Convert to DropdownItem list
      return dataList.map((item) => DropdownItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to load $dropdownType: ${e.toString()}");
    }
  }
}
