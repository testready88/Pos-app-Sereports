import 'package:equatable/equatable.dart';

abstract class BankDetailsEvent extends Equatable {
  const BankDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankDetails extends BankDetailsEvent {
  final String dateTo;

  const LoadBankDetails({
    required this.dateTo,
  });

  @override
  List<Object> get props => [dateTo];
}

class FilterBankDetails extends BankDetailsEvent {
  final String bankName;
  final String locationCode;
  final String dateTo;

  const FilterBankDetails({
    required this.bankName,
    required this.locationCode,
    required this.dateTo,
  });

  @override
  List<Object> get props => [bankName, locationCode, dateTo];
}
