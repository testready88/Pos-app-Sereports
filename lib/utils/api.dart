import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/utils/interceptor.dart';

class ApiException implements Exception {
  final String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() => errorMessage;
}

class LoginResult {
  final bool success;
  final String? token;
  final String? errorMessage;

  const LoginResult({
    required this.success,
    this.token,
    this.errorMessage,
  });

  const LoginResult.ok(this.token)
      : success = true,
        errorMessage = null;

  const LoginResult.fail(String message)
      : success = false,
        token = null,
        errorMessage = message;
}

class Api {
  // SINGLE HTTP CLIENT (IMPORTANT FIX)
  static final InterceptedHttp _client = InterceptedHttp.build(
    interceptors: [SeReportInterceptor()],
  );

  // AUTH SERVER
  static String loginUrl = '${authBaseUrl}auth/login';
  static String userPermissions = '${authBaseUrl}auth/user-permissions';

  // DATA SERVER (UNCHANGED)
  static String dashboardSummary = '${dataBaseUrl}dashboards/summary';
  static String getProductAll = '${dataBaseUrl}products/get-all-product';
  static String getCustomerDetails = '${dataBaseUrl}customers/get-customers-details';
  static String getSupplierDetails = '${dataBaseUrl}suppliers/supplier-details';
  static String getSalesSummary = '${dataBaseUrl}sales-summary/summary-details';
  static String getSalesDetails = '${dataBaseUrl}sales/sales-details';
  static String getPurchaseSummary = '${dataBaseUrl}purchase-summary/summary-details';
  static String getPurchaseDetails = '${dataBaseUrl}purchases/purchase-details';
  static String getIncomeExpensesDetails = '${dataBaseUrl}income-expenses/details';

  static String companyName = '${dataBaseUrl}user/get-user-details';
  static String getBankNameList = '${dataBaseUrl}bank-details/get-all-bank-names';
  static String getBankDetails = '${dataBaseUrl}bank-details/get-all-bank-details';
  static String getBankTransactions = '${dataBaseUrl}banking/bank-transaction-details';
  static String getCategoryNameList = '${dataBaseUrl}categories/get-all-category-name-list';
  static String getSubCategoryNameList = '${dataBaseUrl}sub-categories/get-all-sub-category-name-list';
  static String getSupplierNameList = '${dataBaseUrl}suppliers/get-all-suppliers-name-list';
  static String getCreditorDetailsList = '${dataBaseUrl}suppliers-creditor/get-creditor-details-list';
  static String getSupplierPayableList = '${dataBaseUrl}suppliers/payable-details';
  static String getCustomerDebitors = '${dataBaseUrl}customers/get-debtor-details';
  static String getCustomerRecivables = '${dataBaseUrl}receivables/receivable-details';

  static String lookupItemByBarcode = '${dataBaseUrl}invoice/item-lookup';
  static String createInvoice = '${dataBaseUrl}invoice/create';
  static String calculatePrice = '${dataBaseUrl}invoice/calculate-price';
  static String checkPriceLink = '${dataBaseUrl}invoice/check-price-link';
  static String lastInvPriceByCustomer = '${dataBaseUrl}invoice/last-inv-price-by-customer';
  static String lastInvPriceByItem = '${dataBaseUrl}invoice/last-inv-price-by-item';

  static String searchText = 'searchText';
  static String categoryId = 'categoryId';

  // Accounts
  static String getAssetLedger = '${dataBaseUrl}accounts/asset-ledger';
  static String getAssetSummary = '${dataBaseUrl}accounts/asset-summary';
  static String getCapitalLedger = '${dataBaseUrl}accounts/capital-ledger';
  static String getCapitalSummary = '${dataBaseUrl}accounts/capital-summary';
  static String getCardAccounts = '${dataBaseUrl}accounts/card-accounts';
  static String getCardLedger = '${dataBaseUrl}accounts/card-ledger';
  static String adjustCardBalance = '${dataBaseUrl}accounts/card-adjust-balance';
  static String depositCardToBank = '${dataBaseUrl}accounts/card-deposit-to-bank';
  static String getCashAccounts = '${dataBaseUrl}accounts/cash-accounts';
  static String getCashLedger = '${dataBaseUrl}accounts/cash-ledger';
  static String adjustCashBalance = '${dataBaseUrl}accounts/cash-adjust-balance';
  static String getChequeTransactions = '${dataBaseUrl}accounts/chq-ledger';
  static String chqPass = '${dataBaseUrl}cheques/chq-pass';
  static String chqHold = '${dataBaseUrl}cheques/chq-hold';
  static String chqDeposit = '${dataBaseUrl}cheques/chq-deposit';
  static String chqReturn = '${dataBaseUrl}cheques/chq-return';
  static String getLiabilityLedger = '${dataBaseUrl}accounts/liability-ledger';
  static String getLiabilitySummary = '${dataBaseUrl}accounts/liability-summary';

  static String sqlSafe(String value) => value.replaceAll("'", "''");

  // LOGIN
  static Future<LoginResult> loginCompany(
    String username,
    String password,
    String pinnumber,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(loginUrl),
        body: jsonEncode({
          'username': username,
          'password': password,
          'pinnumber': pinnumber,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      final token = data['token']?.toString();

      if (token != null && token.isNotEmpty) {
        return LoginResult.ok(token);
      }

      return const LoginResult.fail('Invalid login');
    } catch (e) {
      return LoginResult.fail(e.toString());
    }
  }

  // GET USER PERMISSIONS
  static Future<Map<String, dynamic>> getUserPermissions() async {
    return await get(url: userPermissions, parameter: {});
  }

  // GET
  static Future<Map<String, dynamic>> get({
    required String url,
    required Map<String, dynamic> parameter,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        params: parameter.map((k, v) => MapEntry(k, v.toString())),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data);
      }

      throw ApiException(response.body);
    } on SocketException {
      throw ApiException('No Internet Connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // POST
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data);
      }

      throw ApiException(response.body);
    } on SocketException {
      throw ApiException('No Internet Connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}