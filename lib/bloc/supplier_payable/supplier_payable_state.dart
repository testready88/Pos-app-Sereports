import 'package:equatable/equatable.dart';

abstract class SupplierPayableState extends Equatable {
  const SupplierPayableState();

  @override
  List<Object> get props => [];
}

class SupplierPayableInitial extends SupplierPayableState {}

class SupplierPayableLoading extends SupplierPayableState {}

class SupplierPayableLoaded extends SupplierPayableState {
  final List<dynamic> payables;
  final int count;
  final double totalPayableAmount;
  final bool hasReachedMax;
  final int currentPage;
  final String supplierSearch;
  final String invoiceNo;
  final String location;
  final String invGap;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const SupplierPayableLoaded({
    required this.payables,
    required this.count,
    required this.totalPayableAmount,
    required this.hasReachedMax,
    required this.currentPage,
    this.supplierSearch = '',
    this.invoiceNo = '',
    this.location = 'All',
    this.invGap = 'All',
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [
        payables,
        count,
        totalPayableAmount,
        hasReachedMax,
        currentPage,
        supplierSearch,
        invoiceNo,
        location,
        invGap,
        startDate ?? DateTime(2000),
        endDate ?? DateTime(2000),
        isLoading,
      ];

  SupplierPayableLoaded copyWith({
    List<dynamic>? payables,
    int? count,
    double? totalPayableAmount,
    bool? hasReachedMax,
    int? currentPage,
    String? supplierSearch,
    String? invoiceNo,
    String? location,
    String? invGap,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
  }) {
    return SupplierPayableLoaded(
      payables: payables ?? this.payables,
      count: count ?? this.count,
      totalPayableAmount: totalPayableAmount ?? this.totalPayableAmount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      supplierSearch: supplierSearch ?? this.supplierSearch,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      location: location ?? this.location,
      invGap: invGap ?? this.invGap,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SupplierPayableError extends SupplierPayableState {
  final String message;

  const SupplierPayableError(this.message);

  @override
  List<Object> get props => [message];
}
