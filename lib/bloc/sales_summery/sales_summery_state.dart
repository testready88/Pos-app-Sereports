import 'package:equatable/equatable.dart';

abstract class SalesSummaryState extends Equatable {
  const SalesSummaryState();

  @override
  List<Object?> get props => [];
}

class SalesSummaryInitial extends SalesSummaryState {}

class SalesSummaryLoading extends SalesSummaryState {}

class SalesSummaryLoaded extends SalesSummaryState {
  final List<dynamic> salesData;
  final int count;
  final double totalQtySold;
  final double grossSales;
  final double itemDiscount;
  final double netSales;
  final double profitBeforeDiscount;
  final double profitAfterDiscount;
  final double costSales;
  final double exCharges;
  final double advancePayment;
  final double chqPayment;
  final double cardPayment;
  final double creditPayment;
  final double cashPayment;
  final double creditSettlement;
  final double cashDiscount;
  final double pointsRedeem;
  final double voucherPaid;
  final double cashSales;
  final double profitByCashSales;
  final double creditSales;
  final double profitByCreditSales;
  final bool hasReachedMax;
  final int currentPage;
  final String searchCustomer;
  final String locaCode;
  final String paymentType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;

  const SalesSummaryLoaded({
    required this.salesData,
    required this.count,
    required this.totalQtySold,
    required this.grossSales,
    required this.itemDiscount,
    required this.netSales,
    required this.profitBeforeDiscount,
    required this.profitAfterDiscount,
    required this.costSales,
    required this.exCharges,
    required this.advancePayment,
    required this.chqPayment,
    required this.cardPayment,
    required this.creditPayment,
    required this.cashPayment,
    required this.creditSettlement,
    required this.cashDiscount,
    required this.pointsRedeem,
    required this.voucherPaid,
    required this.cashSales,
    required this.profitByCashSales,
    required this.creditSales,
    required this.profitByCreditSales,
    required this.hasReachedMax,
    required this.currentPage,
    this.searchCustomer = '',
    this.locaCode = 'All',
    this.paymentType = 'All',
    this.dateFrom,
    this.dateTo,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        salesData,
        count,
        totalQtySold,
        grossSales,
        itemDiscount,
        netSales,
        profitBeforeDiscount,
        profitAfterDiscount,
        costSales,
        exCharges,
        advancePayment,
        chqPayment,
        cardPayment,
        creditPayment,
        cashPayment,
        creditSettlement,
        cashDiscount,
        pointsRedeem,
        voucherPaid,
        cashSales,
        profitByCashSales,
        creditSales,
        profitByCreditSales,
        hasReachedMax,
        currentPage,
        searchCustomer,
        locaCode,
        paymentType,
        dateFrom,
        dateTo,
        isLoading,
      ];

  SalesSummaryLoaded copyWith({
    List<dynamic>? salesData,
    int? count,
    double? totalQtySold,
    double? grossSales,
    double? itemDiscount,
    double? netSales,
    double? profitBeforeDiscount,
    double? profitAfterDiscount,
    double? costSales,
    double? exCharges,
    double? advancePayment,
    double? chqPayment,
    double? cardPayment,
    double? creditPayment,
    double? cashPayment,
    double? creditSettlement,
    double? cashDiscount,
    double? pointsRedeem,
    double? voucherPaid,
    double? cashSales,
    double? profitByCashSales,
    double? creditSales,
    double? profitByCreditSales,
    bool? hasReachedMax,
    int? currentPage,
    String? searchCustomer,
    String? locaCode,
    String? paymentType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
  }) {
    return SalesSummaryLoaded(
      salesData: salesData ?? this.salesData,
      count: count ?? this.count,
      totalQtySold: totalQtySold ?? this.totalQtySold,
      grossSales: grossSales ?? this.grossSales,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      netSales: netSales ?? this.netSales,
      profitBeforeDiscount: profitBeforeDiscount ?? this.profitBeforeDiscount,
      profitAfterDiscount: profitAfterDiscount ?? this.profitAfterDiscount,
      costSales: costSales ?? this.costSales,
      exCharges: exCharges ?? this.exCharges,
      advancePayment: advancePayment ?? this.advancePayment,
      chqPayment: chqPayment ?? this.chqPayment,
      cardPayment: cardPayment ?? this.cardPayment,
      creditPayment: creditPayment ?? this.creditPayment,
      cashPayment: cashPayment ?? this.cashPayment,
      creditSettlement: creditSettlement ?? this.creditSettlement,
      cashDiscount: cashDiscount ?? this.cashDiscount,
      pointsRedeem: pointsRedeem ?? this.pointsRedeem,
      voucherPaid: voucherPaid ?? this.voucherPaid,
      cashSales: cashSales ?? this.cashSales,
      profitByCashSales: profitByCashSales ?? this.profitByCashSales,
      creditSales: creditSales ?? this.creditSales,
      profitByCreditSales: profitByCreditSales ?? this.profitByCreditSales,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchCustomer: searchCustomer ?? this.searchCustomer,
      locaCode: locaCode ?? this.locaCode,
      paymentType: paymentType ?? this.paymentType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SalesSummaryError extends SalesSummaryState {
  final String message;

  const SalesSummaryError(this.message);

  @override
  List<Object> get props => [message];
}
