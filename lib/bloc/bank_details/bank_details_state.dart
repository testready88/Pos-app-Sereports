import 'package:equatable/equatable.dart';

abstract class BankDetailsState extends Equatable {
  const BankDetailsState();

  @override
  List<Object?> get props => [];
}

class BankDetailsInitial extends BankDetailsState {}

class BankDetailsLoading extends BankDetailsState {}

class BankDetailsLoaded extends BankDetailsState {
  final List<dynamic> bankDetails;
  final double totalBankBalance;
  final String selectedBank;
  final String selectedLocation;

  const BankDetailsLoaded({
    required this.bankDetails,
    required this.totalBankBalance,
    this.selectedBank = 'All',
    this.selectedLocation = 'All',
  });

  @override
  List<Object> get props =>
      [bankDetails, totalBankBalance, selectedBank, selectedLocation];
}

class BankDetailsError extends BankDetailsState {
  final String message;

  const BankDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}
