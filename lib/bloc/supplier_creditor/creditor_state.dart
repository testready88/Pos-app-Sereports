import 'package:equatable/equatable.dart';

abstract class CreditorState extends Equatable {
  const CreditorState();

  @override
  List<Object> get props => [];
}

class CreditorInitial extends CreditorState {}

class CreditorLoading extends CreditorState {}

class CreditorLoaded extends CreditorState {
  final List<dynamic> creditors;
  final int count;
  final double totalOutstandingAmount;
  final bool hasReachedMax;
  final int currentPage;
  final String supplierSearch;
  final String creditSearch;
  final String invGap;
  final String settlementGap;
  final bool isLoading;

  const CreditorLoaded({
    required this.creditors,
    required this.count,
    required this.totalOutstandingAmount,
    required this.hasReachedMax,
    required this.currentPage,
    this.supplierSearch = '',
    this.creditSearch = '',
    this.invGap = 'All',
    this.settlementGap = 'All',
    this.isLoading = false,
  });

  @override
  List<Object> get props => [
        creditors,
        count,
        totalOutstandingAmount,
        hasReachedMax,
        currentPage,
        supplierSearch,
        creditSearch,
        invGap,
        settlementGap,
        isLoading,
      ];

  CreditorLoaded copyWith({
    List<dynamic>? creditors,
    int? count,
    double? totalOutstandingAmount,
    bool? hasReachedMax,
    int? currentPage,
    String? supplierSearch,
    String? creditSearch,
    String? invGap,
    String? settlementGap,
    bool? isLoading,
  }) {
    return CreditorLoaded(
      creditors: creditors ?? this.creditors,
      count: count ?? this.count,
      totalOutstandingAmount:
          totalOutstandingAmount ?? this.totalOutstandingAmount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      supplierSearch: supplierSearch ?? this.supplierSearch,
      creditSearch: creditSearch ?? this.creditSearch,
      invGap: invGap ?? this.invGap,
      settlementGap: settlementGap ?? this.settlementGap,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CreditorError extends CreditorState {
  final String message;

  const CreditorError(this.message);

  @override
  List<Object> get props => [message];
}
