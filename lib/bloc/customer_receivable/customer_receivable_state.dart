import 'package:equatable/equatable.dart';

abstract class ReceivableState extends Equatable {
  const ReceivableState();

  @override
  List<Object?> get props => [];
}

class ReceivableInitial extends ReceivableState {}

class ReceivableLoading extends ReceivableState {}

class ReceivableLoaded extends ReceivableState {
  final List<dynamic> receivables;
  final int totalElements;
  final int currentPage;
  final bool hasReachedMax;
  final double totalAmount;
  final String searchCustomer;
  final String searchInvoice;
  final String locaCode;
  final String invGap;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoadingMore;

  const ReceivableLoaded({
    required this.receivables,
    required this.totalElements,
    required this.currentPage,
    required this.hasReachedMax,
    required this.totalAmount,
    this.searchCustomer = '',
    this.searchInvoice = '',
    this.locaCode = 'All',
    this.invGap = 'All',
    this.dateFrom,
    this.dateTo,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        receivables,
        totalElements,
        currentPage,
        hasReachedMax,
        totalAmount,
        searchCustomer,
        searchInvoice,
        locaCode,
        invGap,
        dateFrom,
        dateTo,
        isLoadingMore,
      ];

  ReceivableLoaded copyWith({
    List<dynamic>? receivables,
    int? totalElements,
    int? currentPage,
    bool? hasReachedMax,
    double? totalAmount,
    String? searchCustomer,
    String? searchInvoice,
    String? locaCode,
    String? invGap,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoadingMore,
  }) {
    return ReceivableLoaded(
      receivables: receivables ?? this.receivables,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalAmount: totalAmount ?? this.totalAmount,
      searchCustomer: searchCustomer ?? this.searchCustomer,
      searchInvoice: searchInvoice ?? this.searchInvoice,
      locaCode: locaCode ?? this.locaCode,
      invGap: invGap ?? this.invGap,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ReceivableError extends ReceivableState {
  final String message;

  const ReceivableError({required this.message});

  @override
  List<Object> get props => [message];
}
