import 'package:equatable/equatable.dart';

abstract class SalesDetailsEvent extends Equatable {
  const SalesDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesDetails extends SalesDetailsEvent {
  final bool refresh;

  const LoadSalesDetails({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreSalesDetails extends SalesDetailsEvent {}

class FilterSalesDetails extends SalesDetailsEvent {
  final String searchItem;
  final String searchCategory;
  final String searchSupplier;
  final String locaCode;
  final String salesType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterSalesDetails({
    this.searchItem = '',
    this.searchCategory = '',
    this.searchSupplier = '',
    this.locaCode = 'All',
    this.salesType = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
        searchItem,
        searchCategory,
        searchSupplier,
        locaCode,
        salesType,
        dateFrom,
        dateTo,
      ];
}

class SearchSalesDetails extends SalesDetailsEvent {
  final String searchText;

  const SearchSalesDetails(this.searchText);

  @override
  List<Object> get props => [searchText];
}
