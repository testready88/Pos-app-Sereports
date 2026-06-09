import 'package:equatable/equatable.dart';

abstract class CustomerDetailsState extends Equatable {
  const CustomerDetailsState();

  @override
  List<Object> get props => [];
}

class CustomerDetailsInitial extends CustomerDetailsState {}

class CustomerDetailsLoading extends CustomerDetailsState {}

class CustomerDetailsLoaded extends CustomerDetailsState {
  final List<dynamic> customers;
  final int count;
  final double totalReceivableAmount;
  final bool hasReachedMax;
  final int currentPage;
  final String searchText;
  final String invGap;
  final bool filterCreditAmount;
  final String settlement;
  final bool isLoading;

  const CustomerDetailsLoaded({
    required this.customers,
    required this.count,
    required this.totalReceivableAmount,
    required this.hasReachedMax,
    required this.currentPage,
    this.searchText = '',
    this.invGap = 'All',
    this.filterCreditAmount = false,
    this.settlement = 'All',
    this.isLoading = false,
  });

  @override
  List<Object> get props => [
        customers,
        count,
        totalReceivableAmount,
        hasReachedMax,
        currentPage,
        searchText,
        invGap,
        filterCreditAmount,
        settlement,
        isLoading,
      ];

  CustomerDetailsLoaded copyWith({
    List<dynamic>? customers,
    int? count,
    double? totalReceivableAmount,
    bool? hasReachedMax,
    int? currentPage,
    String? searchText,
    String? invGap,
    bool? filterCreditAmount,
    String? settlement,
    bool? isLoading,
  }) {
    return CustomerDetailsLoaded(
      customers: customers ?? this.customers,
      count: count ?? this.count,
      totalReceivableAmount:
          totalReceivableAmount ?? this.totalReceivableAmount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      invGap: invGap ?? this.invGap,
      filterCreditAmount: filterCreditAmount ?? this.filterCreditAmount,
      settlement: settlement ?? this.settlement,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CustomerDetailsError extends CustomerDetailsState {
  final String message;

  const CustomerDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
