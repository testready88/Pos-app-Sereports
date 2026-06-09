import 'package:equatable/equatable.dart';

abstract class BankTransactionState extends Equatable {
  const BankTransactionState();

  @override
  List<Object?> get props => [];
}

class BankTransactionInitial extends BankTransactionState {}

class BankTransactionLoading extends BankTransactionState {}

class BankTransactionLoaded extends BankTransactionState {
  final List<dynamic> transactions;
  final int totalElements;
  final int currentPage;
  final bool hasReachedMax;
  final double totalAmount;
  final String locaCode;
  final String bankName;
  final String searchText;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoadingMore;

  const BankTransactionLoaded({
    required this.transactions,
    required this.totalElements,
    required this.currentPage,
    required this.hasReachedMax,
    required this.totalAmount,
    this.locaCode = 'All',
    this.bankName = 'All',
    this.searchText = '',
    this.dateFrom,
    this.dateTo,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        transactions,
        totalElements,
        currentPage,
        hasReachedMax,
        totalAmount,
        locaCode,
        bankName,
        searchText,
        dateFrom,
        dateTo,
        isLoadingMore,
      ];

  BankTransactionLoaded copyWith({
    List<dynamic>? transactions,
    int? totalElements,
    int? currentPage,
    bool? hasReachedMax,
    double? totalAmount,
    String? locaCode,
    String? bankName,
    String? searchText,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoadingMore,
  }) {
    return BankTransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalAmount: totalAmount ?? this.totalAmount,
      locaCode: locaCode ?? this.locaCode,
      bankName: bankName ?? this.bankName,
      searchText: searchText ?? this.searchText,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class BankTransactionError extends BankTransactionState {
  final String message;

  const BankTransactionError({required this.message});

  @override
  List<Object> get props => [message];
}
