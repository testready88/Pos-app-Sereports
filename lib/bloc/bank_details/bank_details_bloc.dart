// ignore_for_file: unused_catch_stack

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sereports/bloc/bank_details/bank_details_event.dart';
import 'package:sereports/bloc/bank_details/bank_details_state.dart';
import 'package:sereports/repository/bank_repo.dart';

class BankDetailsBloc extends Bloc<BankDetailsEvent, BankDetailsState> {
  final BankRepository repository;

  BankDetailsBloc({required this.repository}) : super(BankDetailsInitial()) {
    on<LoadBankDetails>(_onLoadBankDetails);
    on<FilterBankDetails>(_onFilterBankDetails);
  }

  // Helper method to get today's date or use provided date
  String _getDateToUse(String? providedDate) {
    if (providedDate == null ||
        providedDate.isEmpty ||
        providedDate == "Select date") {
      // Return today's date in yyyy-MM-dd format
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    return providedDate;
  }

  Future<void> _onLoadBankDetails(
    LoadBankDetails event,
    Emitter<BankDetailsState> emit,
  ) async {
    emit(BankDetailsLoading());
    try {
      // Use today's date if no date provided
      final dateToUse = _getDateToUse(event.dateTo);

      final response = await repository.getBankDetails(
        bankName: 'All',
        locationCode: 'All',
        dateTo: dateToUse,
      );

      // Extract the data from the response
      final bankDetails = response['bankDetails'] ?? [];
      final totalBankBalance = _extractTotalBalance(response);

      emit(BankDetailsLoaded(
        bankDetails: bankDetails,
        totalBankBalance: totalBankBalance,
      ));
    } catch (e, stackTrace) {
      emit(BankDetailsError(message: 'Failed to load bank details: $e'));
    }
  }

  Future<void> _onFilterBankDetails(
    FilterBankDetails event,
    Emitter<BankDetailsState> emit,
  ) async {
    emit(BankDetailsLoading());
    try {
      // Use today's date if no date provided
      final dateToUse = _getDateToUse(event.dateTo);

      final response = await repository.getBankDetails(
        bankName: event.bankName,
        locationCode: event.locationCode,
        dateTo: dateToUse,
      );

      // Extract the data from the response
      final bankDetails = response['bankDetails'] ?? [];
      final totalBankBalance = _extractTotalBalance(response);

      emit(BankDetailsLoaded(
        bankDetails: bankDetails,
        totalBankBalance: totalBankBalance,
        selectedBank: event.bankName,
        selectedLocation: event.locationCode,
      ));
    } catch (e, stackTrace) {
      emit(BankDetailsError(message: 'Failed to filter bank details: $e'));
    }
  }

  // Helper method to extract total balance from response
  double _extractTotalBalance(Map<String, dynamic> response) {
    try {
      if (response['responseBankSummaryDTO'] != null &&
          response['responseBankSummaryDTO']['totalBankBalance'] != null) {
        final total = response['responseBankSummaryDTO']['totalBankBalance'];
        if (total is num) {
          return total.toDouble();
        } else if (total is String) {
          return double.tryParse(total) ?? 0.0;
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
