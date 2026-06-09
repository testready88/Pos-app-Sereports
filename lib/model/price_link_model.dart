import 'package:big_decimal/big_decimal.dart';

class PriceLinkModel {
  final String stockId;
  final BigDecimal itemUPrice;
  final BigDecimal itemSPrice;
  final BigDecimal? itemDPrice;
  final BigDecimal? itemWPrice;
  final BigDecimal? itemLDPrice;
  final BigDecimal? itemOPrice;
  final BigDecimal? itemCusCatPrice1;
  final BigDecimal? itemCusCatPrice2;
  final BigDecimal? itemCusCatPrice3;
  final BigDecimal? itemCusCatPrice4;
  final BigDecimal? itemCusCatPrice5;
  final BigDecimal? qtyRemain;
  final String? itemBarcode;
  final String? itemName;

  PriceLinkModel({
    required this.stockId,
    required this.itemUPrice,
    required this.itemSPrice,
    this.itemDPrice,
    this.itemWPrice,
    this.itemLDPrice,
    this.itemOPrice,
    this.itemCusCatPrice1,
    this.itemCusCatPrice2,
    this.itemCusCatPrice3,
    this.itemCusCatPrice4,
    this.itemCusCatPrice5,
    this.qtyRemain,
    this.itemBarcode,
    this.itemName,
  });

  factory PriceLinkModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numeric values (handles both string and num)
    BigDecimal? parsePrice(dynamic value) {
      if (value == null) return null;
      try {
        if (value is num) {
          return BigDecimal.parse(value.toString());
        }
        if (value is String) {
          final parsed = num.tryParse(value);
          if (parsed != null) {
            return BigDecimal.parse(parsed.toString());
          }
        }
        return null;
      } catch (e) {
        print('Error parsing price value: $value, error: $e');
        return null;
      }
    }
    
    final parsedItemDPrice = parsePrice(json['itemDPrice']);
    final parsedItemOPrice = parsePrice(json['itemOPrice']);
    
    print('PriceLinkModel.fromJson - Parsing prices:');
    print('  itemSPrice: ${json['itemSPrice']} -> ${parsePrice(json['itemSPrice'] ?? 0)}');
    print('  itemDPrice: ${json['itemDPrice']} -> $parsedItemDPrice');
    print('  itemOPrice: ${json['itemOPrice']} -> $parsedItemOPrice');
    
    return PriceLinkModel(
      stockId: json['stockId']?.toString() ?? '',
      itemUPrice: BigDecimal.parse(
        ((json['itemUPrice'] as num?) ?? 0).toString(),
      ),
      itemSPrice: BigDecimal.parse(
        ((json['itemSPrice'] as num?) ?? 0).toString(),
      ),
      itemDPrice: parsedItemDPrice,
      itemWPrice: parsePrice(json['itemWPrice']),
      itemLDPrice: parsePrice(json['itemLDPrice']),
      itemOPrice: parsedItemOPrice,
      itemCusCatPrice1: parsePrice(json['itemCusCatPrice1']),
      itemCusCatPrice2: parsePrice(json['itemCusCatPrice2']),
      itemCusCatPrice3: parsePrice(json['itemCusCatPrice3']),
      itemCusCatPrice4: parsePrice(json['itemCusCatPrice4']),
      itemCusCatPrice5: parsePrice(json['itemCusCatPrice5']),
      qtyRemain: parsePrice(json['qtyRemain']),
      itemBarcode: json['itemBarcode']?.toString(),
      itemName: json['itemName']?.toString(),
    );
  }

  /// Get price based on price category
  /// RETAIL: itemDPrice (discount price) > itemOPrice (offer price) > itemSPrice (selling price)
  /// WHOLESALE: itemWPrice (wholesale price)
  /// CATEGORY1-5: itemCusCatPrice1-5 (category price 1-5)
  /// LOYALTY DISCOUNT: itemLDPrice (loyalty discount price)
  BigDecimal? getPriceByCategory(String priceCategory) {
    final category = priceCategory.toUpperCase().trim();
    
    switch (category) {
      case 'RETAIL':
        // RETAIL: Try itemDPrice (discount price) first, then itemOPrice (offer price), then itemSPrice (selling price)
        if (itemDPrice != null && itemDPrice! > BigDecimal.zero) {
          return itemDPrice; // Discount price
        }
        if (itemOPrice != null && itemOPrice! > BigDecimal.zero) {
          return itemOPrice; // Offer price
        }
        return itemSPrice; // Selling price (always available)
      
      case 'WHOLESALE':
        // WHOLESALE: Use itemWPrice (wholesale price)
        if (itemWPrice != null && itemWPrice! > BigDecimal.zero) {
          return itemWPrice;
        }
        // If wholesale price is 0 or null, fallback to selling price
        return itemSPrice;
      
      case 'CATEGORY1':
        // CATEGORY1: Use itemCusCatPrice1 (category price 1)
        if (itemCusCatPrice1 != null && itemCusCatPrice1! > BigDecimal.zero) {
          return itemCusCatPrice1;
        }
        return itemSPrice; // Fallback to selling price
      
      case 'CATEGORY2':
        // CATEGORY2: Use itemCusCatPrice2 (category price 2)
        if (itemCusCatPrice2 != null && itemCusCatPrice2! > BigDecimal.zero) {
          return itemCusCatPrice2;
        }
        return itemSPrice;
      
      case 'CATEGORY3':
        // CATEGORY3: Use itemCusCatPrice3 (category price 3)
        if (itemCusCatPrice3 != null && itemCusCatPrice3! > BigDecimal.zero) {
          return itemCusCatPrice3;
        }
        return itemSPrice;
      
      case 'CATEGORY4':
        // CATEGORY4: Use itemCusCatPrice4 (category price 4)
        if (itemCusCatPrice4 != null && itemCusCatPrice4! > BigDecimal.zero) {
          return itemCusCatPrice4;
        }
        return itemSPrice;
      
      case 'CATEGORY5':
        // CATEGORY5: Use itemCusCatPrice5 (category price 5)
        if (itemCusCatPrice5 != null && itemCusCatPrice5! > BigDecimal.zero) {
          return itemCusCatPrice5;
        }
        return itemSPrice;
      
      case 'LOYALTY DISCOUNT':
        // LOYALTY DISCOUNT: Use itemLDPrice (loyalty discount price)
        if (itemLDPrice != null && itemLDPrice! > BigDecimal.zero) {
          return itemLDPrice;
        }
        return itemSPrice; // Fallback to selling price
      
      default:
        // Default to selling price if category not recognized
        return itemSPrice;
    }
  }

  Map<String, dynamic> toJson() => {
        'stockId': stockId,
        'itemUPrice': itemUPrice.toString(),
        'itemSPrice': itemSPrice.toString(),
        'itemDPrice': itemDPrice?.toString(),
        'itemWPrice': itemWPrice?.toString(),
        'itemLDPrice': itemLDPrice?.toString(),
        'itemOPrice': itemOPrice?.toString(),
        'itemCusCatPrice1': itemCusCatPrice1?.toString(),
        'itemCusCatPrice2': itemCusCatPrice2?.toString(),
        'itemCusCatPrice3': itemCusCatPrice3?.toString(),
        'itemCusCatPrice4': itemCusCatPrice4?.toString(),
        'itemCusCatPrice5': itemCusCatPrice5?.toString(),
        'qtyRemain': qtyRemain?.toString(),
        'itemBarcode': itemBarcode,
        'itemName': itemName,
      };
}



