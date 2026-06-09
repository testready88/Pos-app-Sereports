import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankNames extends BankEvent {
  const LoadBankNames();

  @override
  String toString() => 'LoadBankNames';
}
