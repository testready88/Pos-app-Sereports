import 'package:big_decimal/big_decimal.dart';
import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String itemCode;
  final String itemBarcode;
  final String itemName;
  final String stockId;
  final int qty;
  final BigDecimal itemUPrice;
  final BigDecimal itemSPrice;
  final BigDecimal itemDPrice;
  final BigDecimal tPrice;
  final String invType;
  final String? priceCategory; // Price category used (RETAIL, WHOLESALE, etc.)

  const InvoiceItem({
    required this.itemCode,
    required this.itemBarcode,
    required this.itemName,
    required this.stockId,
    required this.qty,
    required this.itemUPrice,
    required this.itemSPrice,
    required this.itemDPrice,
    required this.tPrice,
    required this.invType,
    this.priceCategory,
  });

  InvoiceItem copyWith({
    String? itemCode,
    String? itemBarcode,
    String? itemName,
    String? stockId,
    int? qty,
    BigDecimal? itemUPrice,
    BigDecimal? itemSPrice,
    BigDecimal? itemDPrice,
    BigDecimal? tPrice,
    String? invType,
    String? priceCategory,
  }) {
    return InvoiceItem(
      itemCode: itemCode ?? this.itemCode,
      itemBarcode: itemBarcode ?? this.itemBarcode,
      itemName: itemName ?? this.itemName,
      stockId: stockId ?? this.stockId,
      qty: qty ?? this.qty,
      itemUPrice: itemUPrice ?? this.itemUPrice,
      itemSPrice: itemSPrice ?? this.itemSPrice,
      itemDPrice: itemDPrice ?? this.itemDPrice,
      tPrice: tPrice ?? this.tPrice,
      invType: invType ?? this.invType,
      priceCategory: priceCategory ?? this.priceCategory,
    );
  }

  @override
  List<Object?> get props => [
        itemCode,
        itemBarcode,
        itemName,
        stockId,
        qty,
        itemUPrice,
        itemSPrice,
        itemDPrice,
        tPrice,
        invType,
        priceCategory,
      ];

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        'itemBarcode': itemBarcode,
        'itemName': itemName,
        'stockId': stockId,
        'qty': qty,
        'itemUPrice': itemUPrice.toString(),
        'itemSPrice': itemSPrice.toString(),
        'itemDPrice': itemDPrice.toString(),
        'tPrice': tPrice.toString(),
        'invType': invType,
        if (priceCategory != null) 'priceCategory': priceCategory,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        itemCode: json['itemCode'] ?? '',
        itemBarcode: json['itemBarcode'] ?? '',
        itemName: json['itemName'] ?? '',
        stockId: json['stockId'] ?? '',
        qty: json['qty'] ?? 0,
        itemUPrice: BigDecimal.parse(json['itemUPrice'] ?? '0'),
        itemSPrice: BigDecimal.parse(json['itemSPrice'] ?? '0'),
        itemDPrice: BigDecimal.parse(json['itemDPrice'] ?? '0'),
        tPrice: BigDecimal.parse(json['tPrice'] ?? '0'),
        invType: json['invType'] ?? '',
        priceCategory: json['priceCategory'],
      );
}
