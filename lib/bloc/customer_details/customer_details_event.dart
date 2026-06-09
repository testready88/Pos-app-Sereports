import 'package:equatable/equatable.dart';

abstract class CustomerDetailsEvent extends Equatable {
  const CustomerDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomerDetails extends CustomerDetailsEvent {
  final bool refresh;

  const LoadCustomerDetails({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreCustomerDetails extends CustomerDetailsEvent {}

class FilterCustomerDetails extends CustomerDetailsEvent {
  final String searchText;
  final String invGap;
  final bool filterCreditAmount;
  final String settlement;

  const FilterCustomerDetails({
    this.searchText = '',
    this.invGap = 'All',
    this.filterCreditAmount = false,
    this.settlement = 'All',
  });

  @override
  List<Object> get props =>
      [searchText, invGap, filterCreditAmount, settlement];
}

class SearchCustomer extends CustomerDetailsEvent {
  final String searchText;

  const SearchCustomer(this.searchText);

  @override
  List<Object> get props => [searchText];
}
