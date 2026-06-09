import 'package:sereports/model/invoiceitem.dart';
import 'package:equatable/equatable.dart';
import 'package:big_decimal/big_decimal.dart';

class Invoice extends Equatable {
  final String? id;
  final String customerCode;
  final String customerName;
  final String locaCode;
  final String unitNo;
  final String compId;
  final String invType;
  final List<InvoiceItem> items;
  final BigDecimal grandTotal;
  final DateTime createdAt;
  final String syncStatus; // PENDING, SYNCED, FAILED
  final String? syncError;
  final String? invoiceNo;
  final String? serialNo;

  const Invoice({
    this.id,
    required this.customerCode,
    required this.customerName,
    required this.locaCode,
    required this.unitNo,
    required this.compId,
    required this.invType,
    required this.items,
    required this.grandTotal,
    required this.createdAt,
    this.syncStatus = 'PENDING',
    this.syncError,
    this.invoiceNo,
    this.serialNo,
  });

  @override
  List<Object?> get props => [
        id,
        customerCode,
        customerName,
        locaCode,
        unitNo,
        compId,
        invType,
        items,
        grandTotal,
        createdAt,
        syncStatus,
        syncError,
        invoiceNo,
        serialNo,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerCode': customerCode,
        'customerName': customerName,
        'locaCode': locaCode,
        'unitNo': unitNo,
        'compId': compId,
        'invType': invType,
        'items': items.map((i) => i.toJson()).toList(),
        'grandTotal': grandTotal.toString(),
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus,
        'syncError': syncError,
        'invoiceNo': invoiceNo,
        'serialNo': serialNo,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        customerCode: json['customerCode'] ?? '',
        customerName: json['customerName'] ?? '',
        locaCode: json['locaCode'] ?? '',
        unitNo: json['unitNo'] ?? '',
        compId: json['compId'] ?? '',
        invType: json['invType'] ?? '',
        items: (json['items'] as List?)
                ?.map((i) => InvoiceItem.fromJson(i))
                .toList() ??
            [],
        grandTotal: BigDecimal.parse(json['grandTotal'] ?? '0'),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        syncStatus: json['syncStatus'] ?? 'PENDING',
        syncError: json['syncError'],
        invoiceNo: json['invoiceNo'],
        serialNo: json['serialNo'],
      );

  Invoice copyWith({
    String? id,
    String? customerCode,
    String? customerName,
    String? locaCode,
    String? unitNo,
    String? compId,
    String? invType,
    List<InvoiceItem>? items,
    BigDecimal? grandTotal,
    DateTime? createdAt,
    String? syncStatus,
    String? syncError,
    String? invoiceNo,
    String? serialNo,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      customerName: customerName ?? this.customerName,
      locaCode: locaCode ?? this.locaCode,
      unitNo: unitNo ?? this.unitNo,
      compId: compId ?? this.compId,
      invType: invType ?? this.invType,
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      serialNo: serialNo ?? this.serialNo,
    );
  }
}
