import 'package:equatable/equatable.dart';

abstract class IncomeExpensesState extends Equatable {
  const IncomeExpensesState();

  @override
  List<Object?> get props => [];
}

class IncomeExpensesInitial extends IncomeExpensesState {}

class IncomeExpensesLoading extends IncomeExpensesState {}

class IncomeExpensesLoaded extends IncomeExpensesState {
  final List<dynamic> incomeExpensesData;
  final int count;
  final double netIncome;
  final double netExpenses;
  final double netAmount;
  final bool hasReachedMax;
  final int currentPage;
  final String searchDescription;
  final String searchVendor;
  final String locaCode;
  final String invType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isLoading;

  const IncomeExpensesLoaded({
    required this.incomeExpensesData,
    required this.count,
    required this.netIncome,
    required this.netExpenses,
    required this.netAmount,
    required this.hasReachedMax,
    required this.currentPage,
    this.searchDescription = '',
    this.searchVendor = '',
    this.locaCode = 'All',
    this.invType = 'All',
    this.dateFrom,
    this.dateTo,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        incomeExpensesData,
        count,
        netIncome,
        netExpenses,
        netAmount,
        hasReachedMax,
        currentPage,
        searchDescription,
        searchVendor,
        locaCode,
        invType,
        dateFrom,
        dateTo,
        isLoading,
      ];

  IncomeExpensesLoaded copyWith({
    List<dynamic>? incomeExpensesData,
    int? count,
    double? netIncome,
    double? netExpenses,
    double? netAmount,
    bool? hasReachedMax,
    int? currentPage,
    String? searchDescription,
    String? searchVendor,
    String? locaCode,
    String? invType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isLoading,
  }) {
    return IncomeExpensesLoaded(
      incomeExpensesData: incomeExpensesData ?? this.incomeExpensesData,
      count: count ?? this.count,
      netIncome: netIncome ?? this.netIncome,
      netExpenses: netExpenses ?? this.netExpenses,
      netAmount: netAmount ?? this.netAmount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchDescription: searchDescription ?? this.searchDescription,
      searchVendor: searchVendor ?? this.searchVendor,
      locaCode: locaCode ?? this.locaCode,
      invType: invType ?? this.invType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class IncomeExpensesError extends IncomeExpensesState {
  final String message;

  const IncomeExpensesError(this.message);

  @override
  List<Object> get props => [message];
}
