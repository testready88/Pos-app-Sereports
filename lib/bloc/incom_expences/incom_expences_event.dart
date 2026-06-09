import 'package:equatable/equatable.dart';

abstract class IncomeExpensesEvent extends Equatable {
  const IncomeExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomeExpenses extends IncomeExpensesEvent {
  final bool refresh;

  const LoadIncomeExpenses({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreIncomeExpenses extends IncomeExpensesEvent {}

class FilterIncomeExpenses extends IncomeExpensesEvent {
  final String searchDescription;
  final String searchVendor;
  final String locaCode;
  final String invType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterIncomeExpenses({
    this.searchDescription = '',
    this.searchVendor = '',
    this.locaCode = 'All',
    this.invType = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
        searchDescription,
        searchVendor,
        locaCode,
        invType,
        dateFrom,
        dateTo,
      ];
}

class SearchIncomeExpenses extends IncomeExpensesEvent {
  final String searchText;

  const SearchIncomeExpenses(this.searchText);

  @override
  List<Object> get props => [searchText];
}
