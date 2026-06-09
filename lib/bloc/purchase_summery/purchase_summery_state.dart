import 'package:equatable/equatable.dart';

abstract class PurchaseSummaryState extends Equatable {
  const PurchaseSummaryState();

  @override
  List<Object?> get props => [];
}

class PurchaseSummaryInitial extends PurchaseSummaryState {}

class PurchaseSummaryLoading extends PurchaseSummaryState {}

class PurchaseSummaryLoaded extends PurchaseSummaryState {
  final List<dynamic> purchaseSummaryData;
  final int count;
  final double totalQtyPur;
  final double grossPurchase;
  final double itemDiscountPur;
  final double netPurchase;
  final double cashDiscountPur;
  final double advancePaymentPur;
  final double chqPaymentPur;
  final double cardPaymentPur;
  final double creditPaymentPur;
  final double cashPaymentPur;
  final double transportCharge;
  final double labourCharge;
  final bool hasReachedMax;
  final int currentPage;
  final String searchSupplier;
  final String searchInvoice;
  final String locaCode;
  final String paymentType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;

  const PurchaseSummaryLoaded({
    required this.purchaseSummaryData,
    required this.count,
    required this.totalQtyPur,
    required this.grossPurchase,
    required this.itemDiscountPur,
    required this.netPurchase,
    required this.cashDiscountPur,
    required this.advancePaymentPur,
    required this.chqPaymentPur,
    required this.cardPaymentPur,
    required this.creditPaymentPur,
    required this.cashPaymentPur,
    required this.transportCharge,
    required this.labourCharge,
    required this.hasReachedMax,
    required this.currentPage,
    this.searchSupplier = '',
    this.searchInvoice = '',
    this.locaCode = 'All',
    this.paymentType = 'All',
    this.dateFrom,
    this.dateTo,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        purchaseSummaryData,
        count,
        totalQtyPur,
        grossPurchase,
        itemDiscountPur,
        netPurchase,
        cashDiscountPur,
        advancePaymentPur,
        chqPaymentPur,
        cardPaymentPur,
        creditPaymentPur,
        cashPaymentPur,
        transportCharge,
        labourCharge,
        hasReachedMax,
        currentPage,
        searchSupplier,
        searchInvoice,
        locaCode,
        paymentType,
        dateFrom,
        dateTo,
        isLoading,
      ];

  PurchaseSummaryLoaded copyWith({
    List<dynamic>? purchaseSummaryData,
    int? count,
    double? totalQtyPur,
    double? grossPurchase,
    double? itemDiscountPur,
    double? netPurchase,
    double? cashDiscountPur,
    double? advancePaymentPur,
    double? chqPaymentPur,
    double? cardPaymentPur,
    double? creditPaymentPur,
    double? cashPaymentPur,
    double? transportCharge,
    double? labourCharge,
    bool? hasReachedMax,
    int? currentPage,
    String? searchSupplier,
    String? searchInvoice,
    String? locaCode,
    String? paymentType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
  }) {
    return PurchaseSummaryLoaded(
      purchaseSummaryData: purchaseSummaryData ?? this.purchaseSummaryData,
      count: count ?? this.count,
      totalQtyPur: totalQtyPur ?? this.totalQtyPur,
      grossPurchase: grossPurchase ?? this.grossPurchase,
      itemDiscountPur: itemDiscountPur ?? this.itemDiscountPur,
      netPurchase: netPurchase ?? this.netPurchase,
      cashDiscountPur: cashDiscountPur ?? this.cashDiscountPur,
      advancePaymentPur: advancePaymentPur ?? this.advancePaymentPur,
      chqPaymentPur: chqPaymentPur ?? this.chqPaymentPur,
      cardPaymentPur: cardPaymentPur ?? this.cardPaymentPur,
      creditPaymentPur: creditPaymentPur ?? this.creditPaymentPur,
      cashPaymentPur: cashPaymentPur ?? this.cashPaymentPur,
      transportCharge: transportCharge ?? this.transportCharge,
      labourCharge: labourCharge ?? this.labourCharge,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchSupplier: searchSupplier ?? this.searchSupplier,
      searchInvoice: searchInvoice ?? this.searchInvoice,
      locaCode: locaCode ?? this.locaCode,
      paymentType: paymentType ?? this.paymentType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PurchaseSummaryError extends PurchaseSummaryState {
  final String message;

  const PurchaseSummaryError(this.message);

  @override
  List<Object> get props => [message];
}
