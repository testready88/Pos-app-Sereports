// ignore_for_file: unused_catch_stack

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_event.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_state.dart';
import 'package:sereports/repository/bank_repo.dart';

class BankTransactionBloc
    extends Bloc<BankTransactionEvent, BankTransactionState> {
  final BankRepository bankRepo;

  BankTransactionBloc({required this.bankRepo})
      : super(BankTransactionInitial()) {
    on<LoadBankTransactions>(_onLoadBankTransactions);
    on<LoadMoreBankTransactions>(_onLoadMoreBankTransactions);
    on<FilterBankTransactions>(_onFilterBankTransactions);
    on<SearchBankTransactions>(_onSearchBankTransactions);
  }

  Future<void> _onLoadBankTransactions(
    LoadBankTransactions event,
    Emitter<BankTransactionState> emit,
  ) async {
    emit(BankTransactionLoading());
    try {
      final response = await bankRepo.getBankTransactions(
        page: 0,
        size: 10,
        locaCode: 'All',
        bankName: 'All',
        searchText: '',
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      // Extract data from the response
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert total amount to double
      double totalAmount = response['totalAmount'];

      emit(BankTransactionLoaded(
        transactions: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      emit(BankTransactionError(
          message: 'Failed to load bank transactions: $e'));
    }
  }

  Future<void> _onLoadMoreBankTransactions(
    LoadMoreBankTransactions event,
    Emitter<BankTransactionState> emit,
  ) async {
    if (state is BankTransactionLoaded) {
      final currentState = state as BankTransactionLoaded;

      if (currentState.hasReachedMax) return;

      // Emit loading more state to show loading indicator
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.currentPage + 1;

        final response = await bankRepo.getBankTransactions(
          page: nextPage,
          size: 10,
          locaCode: event.locaCode,
          bankName: event.bankName,
          searchText: event.searchText,
          dateFrom: event.dateFrom ?? currentState.dateFrom,
          dateTo: event.dateTo ?? currentState.dateTo,
        );

        // Extract data safely
        final List<dynamic> newData = response['data'] ?? [];
        final totalElements =
            response['totalElements'] ?? currentState.totalElements;

        // Safely convert totalAmount
        double totalAmount = response['totalAmount'];
        // Emit new loaded state with additional data
        emit(BankTransactionLoaded(
          transactions: [...currentState.transactions, ...newData],
          totalElements: totalElements,
          currentPage: nextPage,
          hasReachedMax: newData.length < 10,
          totalAmount: totalAmount,
          locaCode: event.locaCode,
          bankName: event.bankName,
          searchText: event.searchText,
          dateFrom: event.dateFrom ?? currentState.dateFrom,
          dateTo: event.dateTo ?? currentState.dateTo,
          isLoadingMore: false,
        ));
      } catch (e, stackTrace) {
        // Keep the current state but emit error message
        emit(BankTransactionError(
            message: 'Failed to load more bank transactions: $e'));

        // Revert to previous loaded state to allow retry, but turn off loading indicator
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onFilterBankTransactions(
    FilterBankTransactions event,
    Emitter<BankTransactionState> emit,
  ) async {
    emit(BankTransactionLoading());
    try {
      final response = await bankRepo.getBankTransactions(
        page: 0,
        size: 10,
        locaCode: event.locaCode,
        bankName: event.bankName,
        searchText: event.searchText,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      // Extract data safely
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert totalAmount
      double totalAmount = response['totalAmount'];

      emit(BankTransactionLoaded(
        transactions: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        locaCode: event.locaCode,
        bankName: event.bankName,
        searchText: event.searchText,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      emit(BankTransactionError(
          message: 'Failed to filter bank transactions: $e'));
    }
  }

  Future<void> _onSearchBankTransactions(
    SearchBankTransactions event,
    Emitter<BankTransactionState> emit,
  ) async {
    emit(BankTransactionLoading());
    try {
      final response = await bankRepo.getBankTransactions(
        page: 0,
        size: 10,
        locaCode: 'All',
        bankName: 'All',
        searchText: event.searchText,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      // Extract data safely
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert totalAmount
      double totalAmount = response['totalAmount'];

      emit(BankTransactionLoaded(
        transactions: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        searchText: event.searchText,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      emit(BankTransactionError(
          message: 'Failed to search bank transactions: $e'));
    }
  }
}
