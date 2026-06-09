import 'package:equatable/equatable.dart';

abstract class SupplierDetailsEvent extends Equatable {
  const SupplierDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadSupplierDetails extends SupplierDetailsEvent {
  final int page;
  final int size;
  final String supplierSearch;
  final String creditSearch;
  final String invGap;
  final String settlementGap;
  final bool refresh;

  const LoadSupplierDetails({
    this.page = 0,
    this.size = 10,
    this.supplierSearch = '',
    this.creditSearch = '',
    this.invGap = 'All',
    this.settlementGap = 'All',
    this.refresh = false,
  });

  @override
  List<Object> get props => [
        page,
        size,
        supplierSearch,
        creditSearch,
        invGap,
        settlementGap,
        refresh
      ];
}

// New event for pagination
class LoadMoreSupplierDetails extends SupplierDetailsEvent {}

class ResetSupplierDetails extends SupplierDetailsEvent {}
