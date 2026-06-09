import 'package:equatable/equatable.dart';

abstract class PurchaseSummaryEvent extends Equatable {
  const PurchaseSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchaseSummary extends PurchaseSummaryEvent {
  final bool refresh;

  const LoadPurchaseSummary({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMorePurchaseSummary extends PurchaseSummaryEvent {}

class FilterPurchaseSummary extends PurchaseSummaryEvent {
  final String searchSupplier;
  final String searchInvoice;
  final String locaCode;
  final String paymentType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterPurchaseSummary({
    this.searchSupplier = '',
    this.searchInvoice = '',
    this.locaCode = 'All',
    this.paymentType = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
        searchSupplier,
        searchInvoice,
        locaCode,
        paymentType,
        dateFrom,
        dateTo,
      ];
}

class SearchPurchaseSummary extends PurchaseSummaryEvent {
  final String searchText;

  const SearchPurchaseSummary(this.searchText);

  @override
  List<Object> get props => [searchText];
}
