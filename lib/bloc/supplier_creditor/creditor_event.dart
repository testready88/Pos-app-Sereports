import 'package:equatable/equatable.dart';

abstract class CreditorEvent extends Equatable {
  const CreditorEvent();

  @override
  List<Object> get props => [];
}

class LoadCreditors extends CreditorEvent {
  final bool refresh;

  const LoadCreditors({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreCreditors extends CreditorEvent {}

class FilterCreditors extends CreditorEvent {
  final String supplierSearch;
  final String creditAmount;
  final String invGap;
  final String settlementGap;

  const FilterCreditors({
    this.supplierSearch = '',
    this.creditAmount = '',
    this.invGap = 'All',
    this.settlementGap = 'All',
  });

  @override
  List<Object> get props =>
      [supplierSearch, creditAmount, invGap, settlementGap];
}

class SearchCreditor extends CreditorEvent {
  final String searchText;

  const SearchCreditor(this.searchText);

  @override
  List<Object> get props => [searchText];
}
