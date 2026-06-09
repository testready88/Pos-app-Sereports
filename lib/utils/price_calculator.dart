import 'package:big_decimal/big_decimal.dart';
import 'package:sereports/model/item_detail_model.dart';
import 'package:sereports/model/price_link_model.dart';
import 'package:sereports/model/calculate_price_model.dart';
import 'package:sereports/repository/invoice_create_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PriceCalculator {
  /// Calculate price using backend API
  /// This matches Get_ItemPriceDet logic from .NET code
  static Future<CalculatePriceResponse> calculatePrice({
    required ItemDetailModel itemDetail,
    required PriceLinkModel priceLink,
    required BigDecimal quantity,
    String? priceType,
    bool? isWholesaleMode,
    bool? askOfferDate,
    bool? askDiscountDate,
    bool? askWholeSaleDate,
    bool? prevCusPrice,
    String? customerCode,
    BigDecimal? customerDiscountPrice,
    DateTime? currentDate,
    required BuildContext context,
  }) async {
    try {
      // Get repository from context
      final repository = RepositoryProvider.of<InvoiceRepository>(context);

      // Build request
      final request = CalculatePriceRequest(
        itemCode: itemDetail.itemCode,
        itemBarcode: itemDetail.itemBarcode,
        locaCode: 'DEFAULT', // Backend will handle this
        qty: quantity,
        priceType: priceType,
        customerCode: customerCode,
        prevCusPrice: prevCusPrice,
        itemUPrice: priceLink.itemUPrice,
        itemSPrice: priceLink.itemSPrice,
        itemDPrice: priceLink.itemDPrice,
        askOfferDate: askOfferDate,
        askDiscountDate: askDiscountDate,
        askWholeSaleDate: askWholeSaleDate,
      );

      // Call backend API
      return await repository.calculatePrice(request);
    } catch (e) {
      print('Error calculating price: $e');
      // Return default response on error
      return CalculatePriceResponse(
        itemDPrice: priceLink.itemDPrice ?? priceLink.itemSPrice,
        invType: 'STD',
      );
    }
  }
}

