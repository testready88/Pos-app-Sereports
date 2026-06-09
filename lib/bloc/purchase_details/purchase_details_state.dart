import 'package:equatable/equatable.dart';

abstract class PurchaseHistoryState extends Equatable {
  const PurchaseHistoryState();

  @override
  List<Object?> get props => [];
}

class PurchaseHistoryInitial extends PurchaseHistoryState {}

class PurchaseHistoryLoading extends PurchaseHistoryState {}

class PurchaseHistoryLoaded extends PurchaseHistoryState {
  final List<dynamic> purchaseData;
  final int count;
  final double totalQtyPur;
  final double grossPurchase;
  final double itemDiscountPur;
  final double netPurchase;
  final double transportCharge;
  final double labourCharge;
  final bool hasReachedMax;
  final int currentPage;
  final String searchItem;
  final String searchCategory;
  final String searchSupplier;
  final String locaCode;
  final String purchaseType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;

  const PurchaseHistoryLoaded({
    required this.purchaseData,
    required this.count,
    required this.totalQtyPur,
    required this.grossPurchase,
    required this.itemDiscountPur,
    required this.netPurchase,
    required this.transportCharge,
    required this.labourCharge,
    required this.hasReachedMax,
    required this.currentPage,
    this.searchItem = '',
    this.searchCategory = '',
    this.searchSupplier = '',
    this.locaCode = 'All',
    this.purchaseType = 'All',
    this.dateFrom,
    this.dateTo,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        purchaseData,
        count,
        totalQtyPur,
        grossPurchase,
        itemDiscountPur,
        netPurchase,
        transportCharge,
        labourCharge,
        hasReachedMax,
        currentPage,
        searchItem,
        searchCategory,
        searchSupplier,
        locaCode,
        purchaseType,
        dateFrom,
        dateTo,
        isLoading,
      ];

  PurchaseHistoryLoaded copyWith({
    List<dynamic>? purchaseData,
    int? count,
    double? totalQtyPur,
    double? grossPurchase,
    double? itemDiscountPur,
    double? netPurchase,
    double? transportCharge,
    double? labourCharge,
    bool? hasReachedMax,
    int? currentPage,
    String? searchItem,
    String? searchCategory,
    String? searchSupplier,
    String? locaCode,
    String? purchaseType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
  }) {
    return PurchaseHistoryLoaded(
      purchaseData: purchaseData ?? this.purchaseData,
      count: count ?? this.count,
      totalQtyPur: totalQtyPur ?? this.totalQtyPur,
      grossPurchase: grossPurchase ?? this.grossPurchase,
      itemDiscountPur: itemDiscountPur ?? this.itemDiscountPur,
      netPurchase: netPurchase ?? this.netPurchase,
      transportCharge: transportCharge ?? this.transportCharge,
      labourCharge: labourCharge ?? this.labourCharge,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchItem: searchItem ?? this.searchItem,
      searchCategory: searchCategory ?? this.searchCategory,
      searchSupplier: searchSupplier ?? this.searchSupplier,
      locaCode: locaCode ?? this.locaCode,
      purchaseType: purchaseType ?? this.purchaseType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PurchaseHistoryError extends PurchaseHistoryState {
  final String message;

  const PurchaseHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
