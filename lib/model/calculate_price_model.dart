import 'package:big_decimal/big_decimal.dart';

class CalculatePriceRequest {
  final String itemCode;
  final String? itemBarcode;
  final String? locaCode;
  final BigDecimal qty;
  final String? priceType;
  final String? customerCode;
  final bool? prevCusPrice;
  final bool? cusPriceWithoutPriceLink;
  final BigDecimal? itemUPrice;
  final BigDecimal? itemSPrice;
  final BigDecimal? itemDPrice;
  final BigDecimal? itemWPrice;
  final BigDecimal? itemOPrice;
  final BigDecimal? itemLDPrice;
  final BigDecimal? itemMPrice;
  final BigDecimal? itemCusCatPrice1;
  final BigDecimal? itemCusCatPrice2;
  final BigDecimal? itemCusCatPrice3;
  final BigDecimal? itemCusCatPrice4;
  final BigDecimal? itemCusCatPrice5;
  final bool? askOfferDate;
  final bool? askDiscountDate;
  final bool? askWholeSaleDate;

  CalculatePriceRequest({
    required this.itemCode,
    this.itemBarcode,
    this.locaCode,
    required this.qty,
    this.priceType,
    this.customerCode,
    this.prevCusPrice,
    this.cusPriceWithoutPriceLink,
    this.itemUPrice,
    this.itemSPrice,
    this.itemDPrice,
    this.itemWPrice,
    this.itemOPrice,
    this.itemLDPrice,
    this.itemMPrice,
    this.itemCusCatPrice1,
    this.itemCusCatPrice2,
    this.itemCusCatPrice3,
    this.itemCusCatPrice4,
    this.itemCusCatPrice5,
    this.askOfferDate,
    this.askDiscountDate,
    this.askWholeSaleDate,
  });

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        if (itemBarcode != null) 'itemBarcode': itemBarcode,
        if (locaCode != null) 'locaCode': locaCode,
        'qty': qty.toString(),
        if (priceType != null) 'priceType': priceType,
        if (customerCode != null) 'customerCode': customerCode,
        if (prevCusPrice != null) 'prevCusPrice': prevCusPrice,
        if (cusPriceWithoutPriceLink != null)
          'cusPriceWithoutPriceLink': cusPriceWithoutPriceLink,
        if (itemUPrice != null) 'itemUPrice': itemUPrice.toString(),
        if (itemSPrice != null) 'itemSPrice': itemSPrice.toString(),
        if (itemDPrice != null) 'itemDPrice': itemDPrice.toString(),
        if (itemWPrice != null) 'itemWPrice': itemWPrice.toString(),
        if (itemOPrice != null) 'itemOPrice': itemOPrice.toString(),
        if (itemLDPrice != null) 'itemLDPrice': itemLDPrice.toString(),
        if (itemMPrice != null) 'itemMPrice': itemMPrice.toString(),
        if (itemCusCatPrice1 != null)
          'itemCusCatPrice1': itemCusCatPrice1.toString(),
        if (itemCusCatPrice2 != null)
          'itemCusCatPrice2': itemCusCatPrice2.toString(),
        if (itemCusCatPrice3 != null)
          'itemCusCatPrice3': itemCusCatPrice3.toString(),
        if (itemCusCatPrice4 != null)
          'itemCusCatPrice4': itemCusCatPrice4.toString(),
        if (itemCusCatPrice5 != null)
          'itemCusCatPrice5': itemCusCatPrice5.toString(),
        if (askOfferDate != null) 'askOfferDate': askOfferDate,
        if (askDiscountDate != null) 'askDiscountDate': askDiscountDate,
        if (askWholeSaleDate != null) 'askWholeSaleDate': askWholeSaleDate,
      };
}

class CalculatePriceResponse {
  final BigDecimal itemDPrice;
  final String invType;

  CalculatePriceResponse({
    required this.itemDPrice,
    required this.invType,
  });

  factory CalculatePriceResponse.fromJson(Map<String, dynamic> json) {
    return CalculatePriceResponse(
      itemDPrice: BigDecimal.parse(
        ((json['itemDPrice'] as num?) ?? 0).toString(),
      ),
      invType: json['invType']?.toString() ?? 'STD',
    );
  }
}



