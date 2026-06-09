import 'package:equatable/equatable.dart';

abstract class ReceivableEvent extends Equatable {
  const ReceivableEvent();

  @override
  List<Object?> get props => [];
}

class LoadReceivables extends ReceivableEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadReceivables({
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo];

  @override
  String toString() => 'LoadReceivables';
}

class LoadMoreReceivables extends ReceivableEvent {
  final String searchCustomer;
  final String searchInvoice;
  final String locaCode;
  final String invGap;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadMoreReceivables({
    this.searchCustomer = '',
    this.searchInvoice = '',
    this.locaCode = 'All',
    this.invGap = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props =>
      [searchCustomer, searchInvoice, locaCode, invGap, dateFrom, dateTo];

  @override
  String toString() => 'LoadMoreReceivables';
}

class FilterReceivables extends ReceivableEvent {
  final String searchCustomer;
  final String searchInvoice;
  final String locaCode;
  final String invGap;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const FilterReceivables({
    this.searchCustomer = '',
    this.searchInvoice = '',
    this.locaCode = 'All',
    this.invGap = 'All',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props =>
      [searchCustomer, searchInvoice, locaCode, invGap, dateFrom, dateTo];

  @override
  String toString() => 'FilterReceivables';
}

class SearchReceivables extends ReceivableEvent {
  final String searchCustomer;
  final String searchInvoice;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const SearchReceivables({
    this.searchCustomer = '',
    this.searchInvoice = '',
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [searchCustomer, searchInvoice, dateFrom, dateTo];

  @override
  String toString() =>
      'SearchReceivables { searchCustomer: $searchCustomer, searchInvoice: $searchInvoice }';
}
