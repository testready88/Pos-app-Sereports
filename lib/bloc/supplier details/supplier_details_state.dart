import 'package:equatable/equatable.dart';

abstract class SupplierDetailsState extends Equatable {
  const SupplierDetailsState();

  @override
  List<Object> get props => [];
}

class SupplierDetailsInitial extends SupplierDetailsState {}

class SupplierDetailsLoading extends SupplierDetailsState {}

class SupplierDetailsLoaded extends SupplierDetailsState {
  final List<dynamic> suppliers;
  final int count;
  final double totalOutstandingAmount;
  final int page;
  final int size;
  final String supplierSearch;
  final String creditSearch;
  final String invGap;
  final String settlementGap;
  final bool isSearching;
  final bool hasReachedMax; // Added this property for pagination

  const SupplierDetailsLoaded({
    required this.suppliers,
    required this.count,
    required this.totalOutstandingAmount,
    this.page = 0,
    this.size = 10,
    this.supplierSearch = '',
    this.creditSearch = '',
    this.invGap = 'All',
    this.settlementGap = 'All',
    this.isSearching = false,
    this.hasReachedMax = false, // Default to false
  });

  @override
  List<Object> get props => [
        suppliers,
        count,
        totalOutstandingAmount,
        page,
        size,
        supplierSearch,
        creditSearch,
        invGap,
        settlementGap,
        isSearching,
        hasReachedMax
      ];

  SupplierDetailsLoaded copyWith({
    List<dynamic>? suppliers,
    int? count,
    double? totalOutstandingAmount,
    int? page,
    int? size,
    String? supplierSearch,
    String? creditSearch,
    String? invGap,
    String? settlementGap,
    bool? isSearching,
    bool? hasReachedMax,
  }) {
    return SupplierDetailsLoaded(
      suppliers: suppliers ?? this.suppliers,
      count: count ?? this.count,
      totalOutstandingAmount:
          totalOutstandingAmount ?? this.totalOutstandingAmount,
      page: page ?? this.page,
      size: size ?? this.size,
      supplierSearch: supplierSearch ?? this.supplierSearch,
      creditSearch: creditSearch ?? this.creditSearch,
      invGap: invGap ?? this.invGap,
      settlementGap: settlementGap ?? this.settlementGap,
      isSearching: isSearching ?? this.isSearching,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class SupplierDetailsError extends SupplierDetailsState {
  final String message;

  const SupplierDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
