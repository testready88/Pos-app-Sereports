import 'package:equatable/equatable.dart';

abstract class DebitorsState extends Equatable {
  const DebitorsState();

  @override
  List<Object?> get props => [];
}

class DebitorsInitial extends DebitorsState {}

class DebitorsLoading extends DebitorsState {}

class DebitorsLoaded extends DebitorsState {
  final List<dynamic> debitors;
  final int totalElements;
  final int currentPage;
  final bool hasReachedMax;
  final double totalAmount;
  final String searchText;
  final String invGap;
  final String settlement;
  final String creditAmount;

  const DebitorsLoaded({
    required this.debitors,
    required this.totalElements,
    required this.currentPage,
    required this.hasReachedMax,
    required this.totalAmount,
    this.searchText = '',
    this.invGap = 'All',
    this.settlement = 'All',
    this.creditAmount = '',
  });

  @override
  List<Object?> get props => [
        debitors,
        totalElements,
        currentPage,
        hasReachedMax,
        totalAmount,
        searchText,
        invGap,
        settlement,
        creditAmount,
      ];

  DebitorsLoaded copyWith({
    List<dynamic>? debitors,
    int? totalElements,
    int? currentPage,
    bool? hasReachedMax,
    double? totalAmount,
    String? searchText,
    String? invGap,
    String? settlement,
    String? creditAmount,
  }) {
    return DebitorsLoaded(
      debitors: debitors ?? this.debitors,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalAmount: totalAmount ?? this.totalAmount,
      searchText: searchText ?? this.searchText,
      invGap: invGap ?? this.invGap,
      settlement: settlement ?? this.settlement,
      creditAmount: creditAmount ?? this.creditAmount,
    );
  }
}

class DebitorsError extends DebitorsState {
  final String message;

  const DebitorsError({required this.message});

  @override
  List<Object> get props => [message];
}
