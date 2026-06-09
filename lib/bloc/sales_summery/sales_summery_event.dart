import 'package:equatable/equatable.dart';

abstract class SalesSummaryEvent extends Equatable {
  const SalesSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesSummary extends SalesSummaryEvent {
  final bool refresh;

  const LoadSalesSummary({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreSalesSummary extends SalesSummaryEvent {}

class FilterSalesSummary extends SalesSummaryEvent {
  final String searchCustomer;
  final String locaCode;
  final String paymentType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterSalesSummary({
    this.searchCustomer = '',
    this.locaCode = 'All',
    this.paymentType = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
        searchCustomer,
        locaCode,
        paymentType,
        dateFrom,
        dateTo,
      ];
}

class SearchSalesSummary extends SalesSummaryEvent {
  final String searchText;

  const SearchSalesSummary(this.searchText);

  @override
  List<Object> get props => [searchText];
}
