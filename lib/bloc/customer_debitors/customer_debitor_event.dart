import 'package:equatable/equatable.dart';

abstract class DebitorsEvent extends Equatable {
  const DebitorsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDebitors extends DebitorsEvent {
  const LoadDebitors();

  @override
  String toString() => 'LoadDebitors';
}

class LoadMoreDebitors extends DebitorsEvent {
  final String searchText;
  final String invGap;
  final String settlement;
  final String creditAmount;

  const LoadMoreDebitors({
    this.searchText = '',
    this.invGap = 'All',
    this.settlement = 'All',
    this.creditAmount = '',
  });

  @override
  List<Object?> get props => [searchText, invGap, settlement, creditAmount];

  @override
  String toString() => 'LoadMoreDebitors';
}

class FilterDebitors extends DebitorsEvent {
  final String searchText;
  final String invGap;
  final String settlement;
  final String creditAmount;

  const FilterDebitors({
    this.searchText = '',
    this.invGap = 'All',
    this.settlement = 'All',
    this.creditAmount = '',
  });

  @override
  List<Object?> get props => [searchText, invGap, settlement, creditAmount];

  @override
  String toString() => 'FilterDebitors';
}

class SearchDebitors extends DebitorsEvent {
  final String searchText;

  const SearchDebitors({required this.searchText});

  @override
  List<Object?> get props => [searchText];

  @override
  String toString() => 'SearchDebitors { searchText: $searchText }';
}
