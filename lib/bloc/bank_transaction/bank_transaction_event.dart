import 'package:equatable/equatable.dart';

abstract class BankTransactionEvent extends Equatable {
  const BankTransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankTransactions extends BankTransactionEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadBankTransactions({
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo];

  @override
  String toString() =>
      'LoadBankTransactions(dateFrom: $dateFrom, dateTo: $dateTo)';
}

class LoadMoreBankTransactions extends BankTransactionEvent {
  final String locaCode;
  final String bankName;
  final String searchText;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadMoreBankTransactions({
    this.locaCode = 'All',
    this.bankName = 'All',
    this.searchText = '',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [locaCode, bankName, searchText, dateFrom, dateTo];

  @override
  String toString() =>
      'LoadMoreBankTransactions(locaCode: $locaCode, bankName: $bankName, searchText: $searchText, dateFrom: $dateFrom, dateTo: $dateTo)';
}

class FilterBankTransactions extends BankTransactionEvent {
  final String locaCode;
  final String bankName;
  final String searchText;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterBankTransactions({
    this.locaCode = 'All',
    this.bankName = 'All',
    this.searchText = '',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [locaCode, bankName, searchText, dateFrom, dateTo];

  @override
  String toString() =>
      'FilterBankTransactions(locaCode: $locaCode, bankName: $bankName, searchText: $searchText, dateFrom: $dateFrom, dateTo: $dateTo)';
}

class SearchBankTransactions extends BankTransactionEvent {
  final String searchText;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const SearchBankTransactions({
    required this.searchText,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [searchText, dateFrom, dateTo];

  @override
  String toString() =>
      'SearchBankTransactions(searchText: $searchText, dateFrom: $dateFrom, dateTo: $dateTo)';
}
