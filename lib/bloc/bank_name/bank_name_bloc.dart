// ignore_for_file: unused_catch_stack

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/bank_name/bank_name_event.dart';
import 'package:sereports/bloc/bank_name/bank_name_state.dart';
import 'package:sereports/repository/bank_repo.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final BankRepository bankRepo;

  BankBloc({required this.bankRepo}) : super(BankInitial()) {
    on<LoadBankNames>(_onLoadBankNames);
  }

  Future<void> _onLoadBankNames(
    LoadBankNames event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final bankNames = await bankRepo.getAllBankNames();

      emit(BankLoaded(bankNames: bankNames));
    } catch (e, stackTrace) {
      emit(BankError(message: 'Failed to load bank names: $e'));
    }
  }
}
