import 'package:equatable/equatable.dart';

abstract class SalesDetailsState extends Equatable {
  const SalesDetailsState();

  @override
  List<Object?> get props => [];
}

class SalesDetailsInitial extends SalesDetailsState {}

class SalesDetailsLoading extends SalesDetailsState {}

class SalesDetailsLoaded extends SalesDetailsState {
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
  final String searchItem;
  final String searchCategory;
  final String searchSupplier;
  final String locaCode;
  final String salesType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;

  const SalesDetailsLoaded({
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
    this.searchItem = '',
    this.searchCategory = '',
    this.searchSupplier = '',
    this.locaCode = 'All',
    this.salesType = 'All',
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
        searchItem,
        searchCategory,
        searchSupplier,
        locaCode,
        salesType,
        dateFrom,
        dateTo,
        isLoading,
      ];

  SalesDetailsLoaded copyWith({
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
    String? searchItem,
    String? searchCategory,
    String? searchSupplier,
    String? locaCode,
    String? salesType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
  }) {
    return SalesDetailsLoaded(
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
      searchItem: searchItem ?? this.searchItem,
      searchCategory: searchCategory ?? this.searchCategory,
      searchSupplier: searchSupplier ?? this.searchSupplier,
      locaCode: locaCode ?? this.locaCode,
      salesType: salesType ?? this.salesType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SalesDetailsError extends SalesDetailsState {
  final String message;

  const SalesDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
