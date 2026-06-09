import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_event.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_state.dart';
import 'package:sereports/repository/supplier_repo.dart';

class CreditorBloc extends Bloc<CreditorEvent, CreditorState> {
  final SupplierRepo supplierRepo;
  final int pageSize = 10;

  CreditorBloc({required this.supplierRepo}) : super(CreditorInitial()) {
    on<LoadCreditors>(_onLoadCreditors);
    on<LoadMoreCreditors>(_onLoadMoreCreditors);
    on<FilterCreditors>(_onFilterCreditors);
    on<SearchCreditor>(_onSearchCreditor);
  }

  Future<void> _onLoadCreditors(
    LoadCreditors event,
    Emitter<CreditorState> emit,
  ) async {
    try {
      emit(CreditorLoading());

      final response = await supplierRepo.getCreditorDetailsList(
        page: 0,
        size: pageSize,
        supplierSearch: '',
        creditSearch: '',
        invGap: 'All',
        settlementGap: 'All',
      );

      emit(CreditorLoaded(
        creditors: response['data'],
        totalOutstandingAmount: response['totalOutstandingAmount'],
        count: response['count'],
        hasReachedMax: response['data'].length < pageSize,
        currentPage: 0,
        supplierSearch: '',
        creditSearch: '',
        invGap: 'All',
        settlementGap: 'All',
      ));
    } catch (e) {
      emit(CreditorError(e.toString()));
    }
  }

  Future<void> _onLoadMoreCreditors(
    LoadMoreCreditors event,
    Emitter<CreditorState> emit,
  ) async {
    if (state is CreditorLoaded) {
      final currentState = state as CreditorLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await supplierRepo.getCreditorDetailsList(
          page: nextPage,
          size: pageSize,
          supplierSearch: currentState.supplierSearch,
          creditSearch: currentState.creditSearch,
          invGap: currentState.invGap,
          settlementGap: currentState.settlementGap,
        );

        final newCreditors = response['data'] as List;

        if (newCreditors.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allCreditors = [...currentState.creditors, ...newCreditors];

          emit(currentState.copyWith(
            creditors: allCreditors,
            count: response['count'],
            totalOutstandingAmount: response['totalOutstandingAmount'],
            currentPage: nextPage,
            hasReachedMax: newCreditors.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(CreditorError(e.toString()));
      }
    }
  }

  Future<void> _onFilterCreditors(
    FilterCreditors event,
    Emitter<CreditorState> emit,
  ) async {
    try {
      emit(CreditorLoading());

      final response = await supplierRepo.getCreditorDetailsList(
        page: 0,
        size: pageSize,
        supplierSearch: event.supplierSearch,
        creditSearch: event.creditAmount,
        invGap: event.invGap,
        settlementGap: event.settlementGap,
      );

      emit(CreditorLoaded(
        creditors: response['data'],
        totalOutstandingAmount: response['totalOutstandingAmount'],
        count: response['count'],
        hasReachedMax: response['data'].length < pageSize,
        currentPage: 0,
        supplierSearch: event.supplierSearch,
        creditSearch: event.creditAmount,
        invGap: event.invGap,
        settlementGap: event.settlementGap,
      ));
    } catch (e) {
      emit(CreditorError(e.toString()));
    }
  }

  Future<void> _onSearchCreditor(
    SearchCreditor event,
    Emitter<CreditorState> emit,
  ) async {
    try {
      emit(CreditorLoading());

      String supplierSearch = event.searchText;

      // If already in loaded state, preserve other filters
      String creditSearch = '';
      String invGap = 'All';
      String settlementGap = 'All';

      if (state is CreditorLoaded) {
        final currentState = state as CreditorLoaded;
        creditSearch = currentState.creditSearch;
        invGap = currentState.invGap;
        settlementGap = currentState.settlementGap;
      }

      final response = await supplierRepo.getCreditorDetailsList(
        page: 0,
        size: pageSize,
        supplierSearch: supplierSearch,
        creditSearch: creditSearch,
        invGap: invGap,
        settlementGap: settlementGap,
      );

      emit(CreditorLoaded(
        creditors: response['data'],
        totalOutstandingAmount: response['totalOutstandingAmount'],
        count: response['count'],
        hasReachedMax: response['data'].length < pageSize,
        currentPage: 0,
        supplierSearch: supplierSearch,
        creditSearch: creditSearch,
        invGap: invGap,
        settlementGap: settlementGap,
      ));
    } catch (e) {
      emit(CreditorError(e.toString()));
    }
  }
}
