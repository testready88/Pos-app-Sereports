import 'package:sereports/model/price_link_model.dart';

class ItemDetailModel {
  final String itemCode;
  final String itemBarcode;
  final String itemName;
  final List<PriceLinkModel> priceLinks;
  final bool showPriceLink;
  final bool offer; // chkOffer
  final bool discount; // chkDiscount
  final DateTime? offerValidTill;
  final DateTime? discountValidTill;

  ItemDetailModel({
    required this.itemCode,
    required this.itemBarcode,
    required this.itemName,
    required this.priceLinks,
    this.showPriceLink = false,
    this.offer = false,
    this.discount = false,
    this.offerValidTill,
    this.discountValidTill,
  });

  factory ItemDetailModel.fromJson(Map<String, dynamic> json) {
    final priceLinksData = json['priceLinks'] as List<dynamic>? ?? [];
    final priceLinks = priceLinksData
        .map((pl) => PriceLinkModel.fromJson(pl as Map<String, dynamic>))
        .toList();

    // Parse offerValidTill and discountValidTill dates
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    return ItemDetailModel(
      itemCode: json['itemCode']?.toString() ?? '',
      itemBarcode: json['itemBarcode']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      priceLinks: priceLinks,
      showPriceLink: json['showPriceLink'] == true,
      offer: json['offer'] == true,
      discount: json['discount'] == true,
      offerValidTill: parseDate(json['offerValidTill']),
      discountValidTill: parseDate(json['discountValidTill']),
    );
  }

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        'itemBarcode': itemBarcode,
        'itemName': itemName,
        'priceLinks': priceLinks.map((pl) => pl.toJson()).toList(),
        'showPriceLink': showPriceLink,
        'offer': offer,
        'discount': discount,
        'offerValidTill': offerValidTill?.toIso8601String(),
        'discountValidTill': discountValidTill?.toIso8601String(),
      };
}

