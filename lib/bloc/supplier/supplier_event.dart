import 'package:equatable/equatable.dart';

abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object> get props => [];
}

class LoadSuppliers extends SupplierEvent {
  final String searchText;

  const LoadSuppliers({this.searchText = ''});

  @override
  List<Object> get props => [searchText];
}

class SelectSupplier extends SupplierEvent {
  final String supplierCode;
  final String supplierName;

  const SelectSupplier(
      {required this.supplierCode, required this.supplierName});

  @override
  List<Object> get props => [supplierCode, supplierName];
}
