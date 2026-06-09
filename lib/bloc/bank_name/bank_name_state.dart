import 'package:equatable/equatable.dart';

abstract class BankState extends Equatable {
  const BankState();

  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankLoaded extends BankState {
  final List<String> bankNames;

  const BankLoaded({
    required this.bankNames,
  });

  @override
  List<Object?> get props => [bankNames];
}

class BankError extends BankState {
  final String message;

  const BankError({required this.message});

  @override
  List<Object> get props => [message];
}
