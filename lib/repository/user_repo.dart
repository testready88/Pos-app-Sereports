import 'package:sereports/utils/api.dart';

class UserRepo {
  Future<String> companyName() async {
    try {
      final response = await Api.get(
        url: Api
            .companyName, // This should be defined in your Api class as '/get-all-bank-names'
        parameter: {},
      );

      // Debug the full response

      return response['data'];
    } catch (e, stackTrace) {
      print('Error in getAllBankNames: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load bank names: $e');
    }
  }
}
