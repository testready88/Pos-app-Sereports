// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:math';

import 'package:big_decimal/big_decimal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sereports/db/local_invoice_db.dart';
import 'package:sereports/model/invoiceitem.dart';
import 'package:sereports/model/item_detail_model.dart';
import 'package:sereports/model/calculate_price_model.dart';
import 'package:sereports/model/price_link_model.dart';
import 'package:sereports/utils/api.dart';

class InvoiceRepository {
  final Connectivity connectivity;
  final LocalInvoiceDatabase localDb;

  InvoiceRepository({
    required this.connectivity,
    required this.localDb,
  });

  /// Generate a unique client ID for merge tracking
  String _generateClientId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'CLIENT-$timestamp-$random';
  }

  /// Search items by barcode, name, stockId, or locaCode
  /// Returns a list of items with their price links
  Future<List<Map<String, dynamic>>> searchItems({
    String? searchTerm,
    String? barcode,
    String? stockId,
    String? locaCode,
  }) async {
    print(
        'Searching items with - searchTerm: $searchTerm, barcode: $barcode, stockId: $stockId, locaCode: $locaCode');
    try {
      // Backend requires locaCode and stockId - they cannot be empty
      if (locaCode == null || locaCode.isEmpty) {
        throw Exception('locaCode is required for item lookup');
      }
      if (stockId == null || stockId.isEmpty) {
        throw Exception('stockId is required for item lookup');
      }

      // Prepare parameters according to backend API
      // Backend accepts either barcode OR productName (at least one required)
      final Map<String, dynamic> parameters = {
        'locaCode': locaCode,
        'stockId': stockId,
      };

      // Add barcode if provided, otherwise add productName
      if (barcode != null && barcode.isNotEmpty) {
        parameters['barcode'] = barcode;
      } else if (searchTerm != null && searchTerm.isNotEmpty) {
        parameters['productName'] = searchTerm;
      } else {
        throw Exception('Either barcode or productName must be provided');
      }

      print('Calling API with parameters: $parameters');

      final response = await Api.get(
        url: Api.lookupItemByBarcode,
        parameter: parameters,
      );

      print('Item lookup response: $response');

      // Handle nested data structure
      final itemData = response['data'] as Map<String, dynamic>? ?? response;

      // Extract price links if available
      final priceLinks = itemData['priceLinks'] as List<dynamic>? ?? [];

      // If there are price links, create multiple results
      if (priceLinks.isNotEmpty) {
        return priceLinks.map<Map<String, dynamic>>((priceLink) {
          return {
            'itemCode': itemData['itemCode'] ?? '',
            'itemBarcode': itemData['itemBarcode'] ?? '',
            'itemName': itemData['itemName'] ?? '',
            'stockId': priceLink['stockId'] ?? stockId ?? '',
            'itemUPrice':
                priceLink['itemUPrice'] ?? itemData['itemUPrice'] ?? 0,
            'itemSPrice':
                priceLink['itemSPrice'] ?? itemData['itemSPrice'] ?? 0,
            'itemDPrice': priceLink['itemDPrice'] ??
                priceLink['itemSPrice'] ??
                itemData['itemDPrice'] ??
                0,
            'itemWPrice': priceLink['itemWPrice'],
            'itemLDPrice': priceLink['itemLDPrice'],
            'itemOPrice': priceLink['itemOPrice'],
            'itemCusCatPrice1': priceLink['itemCusCatPrice1'],
            'itemCusCatPrice2': priceLink['itemCusCatPrice2'],
            'itemCusCatPrice3': priceLink['itemCusCatPrice3'],
            'itemCusCatPrice4': priceLink['itemCusCatPrice4'],
            'itemCusCatPrice5': priceLink['itemCusCatPrice5'],
            'invType': itemData['invType'] ?? 'STD',
            'priceLink': priceLink,
          };
        }).toList();
      } else {
        // Single result without price links
        return [
          {
            'itemCode': itemData['itemCode'] ?? '',
            'itemBarcode': itemData['itemBarcode'] ?? '',
            'itemName': itemData['itemName'] ?? '',
            'stockId': stockId,
            'itemUPrice': itemData['itemUPrice'] ?? 0,
            'itemSPrice': itemData['itemSPrice'] ?? 0,
            'itemDPrice': itemData['itemDPrice'] ?? itemData['itemSPrice'] ?? 0,
            'invType': itemData['invType'] ?? 'STD',
          }
        ];
      }
    } catch (e) {
      print('Error searching items: $e');
      rethrow;
    }
  }

  /// Lookup item by barcode with full details and price links
  /// Returns ItemDetailModel with all price links
  /// This matches the Item_Detect() logic from .NET code
  /// Note: stockId is no longer required - only locaCode needed
  Future<ItemDetailModel?> lookupItemWithPriceLinks({
    required String barcode,
    required String locaCode,
    String? productName,
    String? itemCode,
  }) async {
    try {
      print(
          'Looking up item with price links - barcode: $barcode, locaCode: $locaCode, productName: $productName, itemCode: $itemCode');

      final parameters = <String, String>{
        'locaCode': locaCode,
      };

      // Add barcode if provided, otherwise add productName, otherwise use itemCode
      if (barcode.isNotEmpty) {
        parameters['barcode'] = barcode;
      } else if (productName != null && productName.isNotEmpty) {
        parameters['productName'] = productName;
      } else if (itemCode != null && itemCode.isNotEmpty) {
        // Use itemCode as productName (backend will search by name, which might match itemCode)
        // Or we can try using it as barcode
        parameters['barcode'] = itemCode;
      } else {
        throw Exception(
            'Either barcode, productName, or itemCode must be provided');
      }

      final response = await Api.get(
        url: Api.lookupItemByBarcode,
        parameter: parameters,
      );

      print('Item lookup response: $response');

      // Handle nested data structure
      final itemData = response['data'] as Map<String, dynamic>? ?? response;

      if (itemData.isEmpty) {
        return null;
      }

      // Parse into ItemDetailModel
      return ItemDetailModel.fromJson(itemData);
    } catch (e) {
      print('Error looking up item with price links: $e');
      rethrow;
    }
  }

  /// Get last invoice price by customer and item - for Add Item dialog
  /// Returns ItemDPrice and Qty from most recent invoice (filtered by CompID from token)
  Future<Map<String, dynamic>?> fetchLastInvPriceByCustomer({
    required String cusCode,
    required String itemCode,
    String? barcode,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'cusCode': cusCode,
        'itemCode': itemCode,
      };
      if (barcode != null && barcode.isNotEmpty) {
        parameters['barcode'] = barcode;
      }
      final response = await Api.get(
        url: Api.lastInvPriceByCustomer,
        parameter: parameters,
      );
      final data = response['data'] as Map<String, dynamic>?;
      return data;
    } catch (e) {
      print('Error fetching last inv price by customer: $e');
      return null;
    }
  }

  /// Get last invoice price by item only (no customer) - for Add Item dialog
  Future<Map<String, dynamic>?> fetchLastInvPriceByItem({
    required String itemCode,
    String? barcode,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'itemCode': itemCode,
      };
      if (barcode != null && barcode.isNotEmpty) {
        parameters['barcode'] = barcode;
      }
      final response = await Api.get(
        url: Api.lastInvPriceByItem,
        parameter: parameters,
      );
      final data = response['data'] as Map<String, dynamic>?;
      return data;
    } catch (e) {
      print('Error fetching last inv price by item: $e');
      return null;
    }
  }

  /// Check Price Link - Get price links for an item (matches VB6 Check_PriceLink logic)
  /// This returns all price links with all price fields (itemWPrice, itemLDPrice, etc.)
  Future<List<PriceLinkModel>> checkPriceLink({
    required String itemBarcode,
    required String locaCode,
    required String stockId,
    BigDecimal? itemUPrice,
    BigDecimal? itemSPrice,
    bool updateMode = false,
    bool itemPriceShortCutMode = false,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'itemBarcode': itemBarcode,
        'locaCode': locaCode,
        'stockId': stockId,
        'updateMode': updateMode.toString(),
        'itemPriceShortCutMode': itemPriceShortCutMode.toString(),
      };

      if (itemUPrice != null) {
        parameters['itemUPrice'] = itemUPrice.toString();
      }
      if (itemSPrice != null) {
        parameters['itemSPrice'] = itemSPrice.toString();
      }

      final response = await Api.get(
        url: Api.checkPriceLink,
        parameter: parameters,
      );

      print('Check price link response: $response');

      // Handle nested data structure
      final priceLinksData = response['data'] as List<dynamic>? ?? [];

      return priceLinksData
          .map((json) => PriceLinkModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error checking price link: $e');
      rethrow;
    }
  }

  /// Calculate price using backend calculate-price endpoint
  /// This matches the txtQty_Change() logic from .NET code
  Future<CalculatePriceResponse> calculatePrice(
    CalculatePriceRequest request,
  ) async {
    try {
      print('Calculating price with request: ${request.toJson()}');

      final response = await Api.post(
        url: Api.calculatePrice,
        body: request.toJson(),
      );

      print('Calculate price response: $response');

      // Handle nested data structure
      final priceData = response['data'] as Map<String, dynamic>? ?? response;

      return CalculatePriceResponse.fromJson(priceData);
    } catch (e) {
      print('Error calculating price: $e');
      rethrow;
    }
  }

  Future<InvoiceItem> getItemByBarcode(
    String barcode,
    String locaCode,
    String stockId,
  ) async {
    try {
      print('Loading item by barcode: $barcode');

      final response = await Api.get(
        url: Api.lookupItemByBarcode,
        parameter: {
          'barcode': barcode,
          'locaCode': locaCode,
          'stockId': stockId,
        },
      );

      print('Item lookup response: $response');

      // Handle nested data structure based on your API response
      final itemData = response['data'] as Map<String, dynamic>? ?? response;

      return InvoiceItem(
        itemCode: itemData['itemCode'] ?? '',
        itemBarcode: itemData['itemBarcode'] ?? '',
        itemName: itemData['itemName'] ?? '',
        stockId: itemData['stockId'] ?? stockId,
        qty: 1,
        itemUPrice: BigDecimal.parse(
          ((itemData['itemUPrice'] as num?) ?? 0).toString(),
        ),
        itemSPrice: BigDecimal.parse(
          ((itemData['itemSPrice'] as num?) ?? 0).toString(),
        ),
        itemDPrice: BigDecimal.parse(
          ((itemData['itemDPrice'] as num?) ?? 0).toString(),
        ),
        tPrice: BigDecimal.parse(
          ((itemData['itemDPrice'] as num?) ?? 0).toString(),
        ),
        invType: itemData['invType'] ?? 'STD',
      );
    } catch (e) {
      print('Error loading item: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createInvoice({
    required String customerCode,
    required String customerName,
    String? locaCode, // Optional - will be extracted from token in backend
    String? unitNo, // Optional - will use default in backend
    String? compId, // Optional - will be extracted from token in backend
    String? invType, // Optional - will use default in backend
    required List<InvoiceItem> items,
    required BigDecimal grandTotal,
    String? paymentType,
    BigDecimal? cashPaid,
    BigDecimal? cardPaid,
    BigDecimal? creditPaid,
    BigDecimal? bankTransferPaid,
    dynamic chequePayment,
    dynamic cardPayment,
    dynamic bankTransfer,
  }) async {
    try {
      final hasConnection = await connectivity.checkConnectivity();
      final invoiceId = DateTime.now().millisecondsSinceEpoch.toString();
      final clientId =
          _generateClientId(); // Generate unique client ID for merge tracking

      if (hasConnection != ConnectivityResult.none) {
        // Online - try to sync immediately
        try {
          print('Creating invoice online...');

          // Prepare request body
          // Note: locaCode, unitNo, compId, and invType are optional
          // Backend will extract compId from token and use defaults for others
          final requestBody = {
            'clientId': clientId, // Include clientId for merge tracking
            'customerCode': customerCode,
            // Only include optional fields if provided
            if (locaCode != null && locaCode.isNotEmpty) 'locaCode': locaCode,
            if (unitNo != null && unitNo.isNotEmpty) 'unitNo': unitNo,
            if (invType != null && invType.isNotEmpty) 'invType': invType,
            'items': items
                .map((i) => {
                      'itemCode': i.itemCode,
                      'itemBarcode': i.itemBarcode,
                      'stockId': i.stockId,
                      'qty': i.qty,
                      'itemUPrice': i.itemUPrice.toString(),
                      'itemSPrice': i.itemSPrice.toString(),
                      'itemDPrice': i.itemDPrice.toString(),
                      'invType': i.invType,
                      if (i.priceCategory != null)
                        'priceCategory': i.priceCategory,
                    })
                .toList(),
          };

          // Add payment information if provided
          // New format: Payment info is saved directly in header based on payment type
          if (paymentType != null) {
            requestBody['paymentType'] = paymentType;
            
            if (paymentType.toUpperCase() == 'CASH') {
              if (cashPaid != null) {
                requestBody['cashPaid'] = cashPaid.toString();
              }
            } else if (paymentType.toUpperCase() == 'CREDIT') {
              if (creditPaid != null) {
                requestBody['creditPaid'] = creditPaid.toString();
              }
            } else if (paymentType.toUpperCase() == 'CARD') {
              // Extract card payment info from cardPayment DTO
              if (cardPayment != null) {
                try {
                  final cardData = cardPayment.toJson();
                  if (cardData['paidAmount'] != null) {
                    requestBody['cardPaid'] = cardData['paidAmount'].toString();
                  }
                  if (cardData['cardNumber'] != null) {
                    requestBody['cardNo'] = cardData['cardNumber'].toString();
                  }
                  if (cardData['bankName'] != null && cardData['bankName'].toString().isNotEmpty) {
                    requestBody['cardBank'] = cardData['bankName'].toString();
                  }
                } catch (e) {
                  print('Error extracting card info: $e');
                }
              }
              // Fallback: Use cardPaid parameter if provided and cardPayment doesn't have it
              if (cardPaid != null && !requestBody.containsKey('cardPaid')) {
                requestBody['cardPaid'] = cardPaid.toString();
              }
            } else if (paymentType.toUpperCase() == 'CHEQUE') {
              // Extract cheque payment info from chequePayment DTO
              if (chequePayment != null) {
                try {
                  final chequeData = chequePayment.toJson();
                  if (chequeData['paidAmount'] != null) {
                    requestBody['chqPaid'] = chequeData['paidAmount'].toString();
                  }
                  if (chequeData['chequeNumber'] != null) {
                    requestBody['chqNo'] = chequeData['chequeNumber'].toString();
                  }
                  if (chequeData['chequeDate'] != null) {
                    // Format date as YYYY-MM-DD
                    final dateStr = chequeData['chequeDate'].toString();
                    requestBody['chqDate'] = dateStr;
                  }
                  if (chequeData['bankName'] != null && chequeData['bankName'].toString().isNotEmpty) {
                    requestBody['chqBnk'] = chequeData['bankName'].toString();
                  }
                } catch (e) {
                  print('Error extracting cheque info: $e');
                }
              }
            }
          }

          final response = await Api.post(
            url: Api.createInvoice,
            body: requestBody,
          );

          print('Invoice creation response: $response');

          // Extract invoice/serial numbers from response
          final responseData =
              response['data'] as Map<String, dynamic>? ?? response;
          final invoiceNo = responseData['invoiceNo'] ??
              response['invoiceNo'] ??
              'INV-$invoiceId';
          final serialNo = responseData['serialNo'] ??
              response['serialNo'] ??
              'SN-$invoiceId';

          // Update local database with synced status
          await localDb.updateInvoiceSyncStatus(
            invoiceId,
            'SYNCED',
            invoiceNo: invoiceNo,
            serialNo: serialNo,
          );

          return {
            'invoiceNo': invoiceNo,
            'serialNo': serialNo,
            'isSynced': true,
          };
        } catch (e) {
          print('Online creation failed, saving locally: $e');
          // Fallback to offline save
          // Use defaults for optional fields when saving locally
          await localDb.saveInvoice(
            id: invoiceId,
            clientId: clientId,
            customerCode: customerCode,
            customerName: customerName,
            locaCode: locaCode ?? 'DEFAULT',
            unitNo: unitNo ?? '001',
            compId:
                compId ?? 'DEFAULT', // Will be extracted from token when synced
            invType: invType ?? 'RETAIL',
            items: items,
            grandTotal: grandTotal,
            createdAt: DateTime.now(),
            syncStatus: 'PENDING',
            syncError: e.toString(),
            paymentType: paymentType,
            cashPaid: cashPaid,
            cardPaid: cardPaid,
            creditPaid: creditPaid,
            bankTransferPaid: bankTransferPaid,
          );

          return {
            'invoiceNo': 'PENDING-$invoiceId',
            'serialNo': 'PENDING-$invoiceId',
            'isSynced': false,
          };
        }
      } else {
        // Offline - save locally
        print('Creating invoice offline...');
        // Use defaults for optional fields when saving locally
        await localDb.saveInvoice(
          id: invoiceId,
          clientId: clientId,
          customerCode: customerCode,
          customerName: customerName,
          locaCode: locaCode ?? 'DEFAULT',
          unitNo: unitNo ?? '001',
          compId:
              compId ?? 'DEFAULT', // Will be extracted from token when synced
          invType: invType ?? 'RETAIL',
          items: items,
          grandTotal: grandTotal,
          createdAt: DateTime.now(),
          syncStatus: 'PENDING',
          paymentType: paymentType,
          cashPaid: cashPaid,
          cardPaid: cardPaid,
          creditPaid: creditPaid,
          bankTransferPaid: bankTransferPaid,
          holdStatus: 'NONE',
        );

        return {
          'invoiceNo': 'PENDING-$invoiceId',
          'serialNo': 'PENDING-$invoiceId',
          'isSynced': false,
        };
      }
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveAndHoldInvoice({
    required String customerCode,
    required String customerName,
    required List<InvoiceItem> items,
    required BigDecimal grandTotal,
  }) async {
    try {
      final invoiceId = DateTime.now().millisecondsSinceEpoch.toString();
      final clientId =
          DateTime.now().millisecondsSinceEpoch.toString() + invoiceId;

      // Always save locally with hold status
      await localDb.saveInvoice(
        id: invoiceId,
        clientId: clientId,
        customerCode: customerCode,
        customerName: customerName,
        locaCode: 'DEFAULT',
        unitNo: '001',
        compId: 'DEFAULT',
        invType: 'RETAIL',
        items: items.map((i) => i.toJson()).toList(),
        grandTotal: grandTotal,
        createdAt: DateTime.now(),
        syncStatus: 'PENDING',
        holdStatus: 'HELD',
      );

      return {
        'invoiceNo': 'HELD-$invoiceId',
        'serialNo': 'HELD-$invoiceId',
        'isSynced': false,
      };
    } catch (e) {
      print('Error saving and holding invoice: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncPendingInvoices() async {
    try {
      print('Starting sync of pending invoices...');

      final pendingInvoices = await localDb.getPendingInvoices();
      int synced = 0;
      int failed = 0;

      for (var invoiceMap in pendingInvoices) {
        try {
          final invoiceId = invoiceMap['id'] as String;
          final clientId =
              invoiceMap['clientId'] as String? ?? _generateClientId();
          final items = (jsonDecode(invoiceMap['items'] as String) as List)
              .map((i) => InvoiceItem.fromJson(i))
              .toList();

          // Prepare request body
          // Note: locaCode, unitNo, compId, and invType are optional
          // Backend will extract compId from token and use defaults for others
          final locaCodeValue = invoiceMap['locaCode'] as String?;
          final unitNoValue = invoiceMap['unitNo'] as String?;
          final invTypeValue = invoiceMap['invType'] as String?;

          final requestBody = {
            'clientId': clientId, // Include clientId for merge tracking
            'customerCode': invoiceMap['customerCode'],
            // Only include optional fields if they're not defaults
            if (locaCodeValue != null &&
                locaCodeValue.isNotEmpty &&
                locaCodeValue != 'DEFAULT')
              'locaCode': locaCodeValue,
            if (unitNoValue != null &&
                unitNoValue.isNotEmpty &&
                unitNoValue != '001')
              'unitNo': unitNoValue,
            if (invTypeValue != null &&
                invTypeValue.isNotEmpty &&
                invTypeValue != 'RETAIL')
              'invType': invTypeValue,
            'items': items
                .map((i) => {
                      'itemCode': i.itemCode,
                      'itemBarcode': i.itemBarcode,
                      'stockId': i.stockId,
                      'qty': i.qty,
                      'itemUPrice': i.itemUPrice.toString(),
                      'itemSPrice': i.itemSPrice.toString(),
                      'itemDPrice': i.itemDPrice.toString(),
                      'invType': i.invType,
                      if (i.priceCategory != null)
                        'priceCategory': i.priceCategory,
                    })
                .toList(),
          };

          // Add payment information if available
          if (invoiceMap['paymentType'] != null) {
            requestBody['paymentType'] = invoiceMap['paymentType'];
            if (invoiceMap['cashPaid'] != null)
              requestBody['cashPaid'] = invoiceMap['cashPaid'];
            if (invoiceMap['cardPaid'] != null)
              requestBody['cardPaid'] = invoiceMap['cardPaid'];
            if (invoiceMap['creditPaid'] != null)
              requestBody['creditPaid'] = invoiceMap['creditPaid'];
            if (invoiceMap['bankTransferPaid'] != null)
              requestBody['bankTransferPaid'] = invoiceMap['bankTransferPaid'];
          }

          final response = await Api.post(
            url: Api.createInvoice,
            body: requestBody,
          );

          final responseData =
              response['data'] as Map<String, dynamic>? ?? response;
          await localDb.updateInvoiceSyncStatus(
            invoiceId,
            'SYNCED',
            invoiceNo: responseData['invoiceNo'] ?? response['invoiceNo'],
            serialNo: responseData['serialNo'] ?? response['serialNo'],
          );
          synced++;
          print('Invoice synced successfully: $invoiceId');
        } catch (e) {
          print('Error syncing invoice: $e');
          failed++;
        }
      }

      print('Sync complete - Synced: $synced, Failed: $failed');
      return {'synced': synced, 'failed': failed};
    } catch (e) {
      print('Error in sync process: $e');
      rethrow;
    }
  }
}

// ==================== EXTENSION FOR INVOICEITEM ====================

extension InvoiceItemJsonExtension on InvoiceItem {
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemBarcode': itemBarcode,
      'itemName': itemName,
      'stockId': stockId,
      'qty': qty,
      'itemUPrice': itemUPrice,
      'itemSPrice': itemSPrice,
      'itemDPrice': itemDPrice,
      'tPrice': tPrice,
      'invType': invType,
    };
  }

  static InvoiceItem fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemCode: json['itemCode'] ?? '',
      itemBarcode: json['itemBarcode'] ?? '',
      itemName: json['itemName'] ?? '',
      stockId: json['stockId'] ?? '',
      qty: json['qty'] ?? 1,
      itemUPrice: BigDecimal.parse(
        ((json['itemUPrice'] as num?) ?? 0).toString(),
      ),
      itemSPrice: BigDecimal.parse(
        ((json['itemSPrice'] as num?) ?? 0).toString(),
      ),
      itemDPrice: BigDecimal.parse(
        ((json['itemDPrice'] as num?) ?? 0).toString(),
      ),
      tPrice: BigDecimal.parse(
        ((json['itemDPrice'] as num?) ?? 0).toString(),
      ),
      invType: json['invType'] ?? '',
    );
  }
}
