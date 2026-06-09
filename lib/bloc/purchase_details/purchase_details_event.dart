import 'package:equatable/equatable.dart';

abstract class PurchaseHistoryEvent extends Equatable {
  const PurchaseHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchaseHistory extends PurchaseHistoryEvent {
  final bool refresh;

  const LoadPurchaseHistory({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMorePurchaseHistory extends PurchaseHistoryEvent {}

class FilterPurchaseHistory extends PurchaseHistoryEvent {
  final String searchItem;
  final String searchCategory;
  final String searchSupplier;
  final String locaCode;
  final String purchaseType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterPurchaseHistory({
    this.searchItem = '',
    this.searchCategory = '',
    this.searchSupplier = '',
    this.locaCode = 'All',
    this.purchaseType = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
        searchItem,
        searchCategory,
        searchSupplier,
        locaCode,
        purchaseType,
        dateFrom,
        dateTo,
      ];
}

class SearchPurchaseHistory extends PurchaseHistoryEvent {
  final String searchText;

  const SearchPurchaseHistory(this.searchText);

  @override
  List<Object> get props => [searchText];
}
