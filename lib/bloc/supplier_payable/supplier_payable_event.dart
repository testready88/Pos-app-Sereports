import 'package:equatable/equatable.dart';

abstract class SupplierPayableEvent extends Equatable {
  const SupplierPayableEvent();

  @override
  List<Object> get props => [];
}

class LoadSupplierPayables extends SupplierPayableEvent {
  final bool refresh;

  const LoadSupplierPayables({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreSupplierPayables extends SupplierPayableEvent {}

class FilterSupplierPayables extends SupplierPayableEvent {
  final String supplierSearch;
  final String invoiceNo;
  final String location;
  final String invGap;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterSupplierPayables({
    this.supplierSearch = '',
    this.invoiceNo = '',
    this.location = 'All',
    this.invGap = 'All',
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [
        supplierSearch,
        invoiceNo,
        location,
        invGap,
        startDate ?? DateTime(2000),
        endDate ?? DateTime(2000),
      ];
}

class SearchSupplierPayable extends SupplierPayableEvent {
  final String searchText;

  const SearchSupplierPayable(this.searchText);

  @override
  List<Object> get props => [searchText];
}
