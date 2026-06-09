// ignore_for_file: unused_catch_stack

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_event.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_state.dart';
import 'package:sereports/repository/customer_repo.dart';

class ReceivableBloc extends Bloc<ReceivableEvent, ReceivableState> {
  final CustomerRepo customerRepo;

  ReceivableBloc({required this.customerRepo}) : super(ReceivableInitial()) {
    on<LoadReceivables>(_onLoadReceivables);
    on<LoadMoreReceivables>(_onLoadMoreReceivables);
    on<FilterReceivables>(_onFilterReceivables);
    on<SearchReceivables>(_onSearchReceivables);
  }

  Future<void> _onLoadReceivables(
    LoadReceivables event,
    Emitter<ReceivableState> emit,
  ) async {
    emit(ReceivableLoading());
    try {
      print('Loading initial receivables data');
      final response = await customerRepo.getReceivableDetails(
        page: 0,
        size: 10,
        searchCustomer: '',
        searchInvoice: '',
        locaCode: 'All',
        invGap: 'All',
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      print('Got response from repo: $response');

      // Extract data from the response
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert total amount to double
      double totalAmount = 0.0;
      if (response['totalAmount'] != null) {
        if (response['totalAmount'] is num) {
          totalAmount = (response['totalAmount'] as num).toDouble();
        } else {
          try {
            totalAmount = double.parse(response['totalAmount'].toString());
          } catch (e) {
            print('Error converting totalAmount to double: $e');
          }
        }
      }

      print('Emitting ReceivableLoaded with ${data.length} items');
      emit(ReceivableLoaded(
        receivables: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      print('Error in LoadReceivables: $e');
      print('Stack trace: $stackTrace');
      emit(ReceivableError(message: 'Failed to load receivables: $e'));
    }
  }

  Future<void> _onLoadMoreReceivables(
    LoadMoreReceivables event,
    Emitter<ReceivableState> emit,
  ) async {
    if (state is ReceivableLoaded) {
      final currentState = state as ReceivableLoaded;

      if (currentState.hasReachedMax) return;

      // Emit loading more state to show loading indicator
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.currentPage + 1;

        print('Loading more receivables, page: $nextPage');

        final response = await customerRepo.getReceivableDetails(
          page: nextPage,
          size: 10,
          searchCustomer: event.searchCustomer,
          searchInvoice: event.searchInvoice,
          locaCode: event.locaCode,
          invGap: event.invGap,
          dateFrom: event.dateFrom ?? currentState.dateFrom,
          dateTo: event.dateTo ?? currentState.dateTo,
        );

        // Extract data safely
        final List<dynamic> newData = response['data'] ?? [];
        final totalElements =
            response['totalElements'] ?? currentState.totalElements;

        // Safely convert totalAmount
        double totalAmount = currentState.totalAmount;
        if (response['totalAmount'] != null) {
          if (response['totalAmount'] is num) {
            totalAmount = (response['totalAmount'] as num).toDouble();
          } else {
            try {
              totalAmount = double.parse(response['totalAmount'].toString());
            } catch (e) {
              print('Error converting totalAmount to double: $e');
            }
          }
        }

        print('Loaded ${newData.length} more items');

        // Emit new loaded state with additional data
        emit(ReceivableLoaded(
          receivables: [...currentState.receivables, ...newData],
          totalElements: totalElements,
          currentPage: nextPage,
          hasReachedMax: newData.length < 10,
          totalAmount: totalAmount,
          searchCustomer: event.searchCustomer,
          searchInvoice: event.searchInvoice,
          locaCode: event.locaCode,
          invGap: event.invGap,
          dateFrom: event.dateFrom ?? currentState.dateFrom,
          dateTo: event.dateTo ?? currentState.dateTo,
          isLoadingMore: false,
        ));
      } catch (e, stackTrace) {
        print('Error in LoadMoreReceivables: $e');

        // Revert to previous loaded state to allow retry, but turn off loading indicator
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onFilterReceivables(
    FilterReceivables event,
    Emitter<ReceivableState> emit,
  ) async {
    emit(ReceivableLoading());
    try {
      print('Filtering receivables with criteria: ${event.toString()}');

      final response = await customerRepo.getReceivableDetails(
        page: 0,
        size: 10,
        searchCustomer: event.searchCustomer,
        searchInvoice: event.searchInvoice,
        locaCode: event.locaCode,
        invGap: event.invGap,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      // Extract data safely
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert totalAmount
      double totalAmount = 0.0;
      if (response['totalAmount'] != null) {
        if (response['totalAmount'] is num) {
          totalAmount = (response['totalAmount'] as num).toDouble();
        } else {
          try {
            totalAmount = double.parse(response['totalAmount'].toString());
          } catch (e) {
            print('Error converting totalAmount to double: $e');
          }
        }
      }

      print('Filtered results contain ${data.length} items');

      emit(ReceivableLoaded(
        receivables: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        searchCustomer: event.searchCustomer,
        searchInvoice: event.searchInvoice,
        locaCode: event.locaCode,
        invGap: event.invGap,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      print('Error in FilterReceivables: $e');
      print('Stack trace: $stackTrace');
      emit(ReceivableError(message: 'Failed to filter receivables: $e'));
    }
  }

  Future<void> _onSearchReceivables(
    SearchReceivables event,
    Emitter<ReceivableState> emit,
  ) async {
    emit(ReceivableLoading());
    try {
      print('Searching receivables with: ${event.toString()}');

      final response = await customerRepo.getReceivableDetails(
        page: 0,
        size: 10,
        searchCustomer: event.searchCustomer,
        searchInvoice: event.searchInvoice,
        locaCode: 'All',
        invGap: 'All',
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      // Extract data safely
      final List<dynamic> data = response['data'] ?? [];
      final totalElements = response['totalElements'] ?? 0;

      // Safely convert totalAmount
      double totalAmount = 0.0;
      if (response['totalAmount'] != null) {
        if (response['totalAmount'] is num) {
          totalAmount = (response['totalAmount'] as num).toDouble();
        } else {
          try {
            totalAmount = double.parse(response['totalAmount'].toString());
          } catch (e) {
            print('Error converting totalAmount to double: $e');
          }
        }
      }

      print('Search returned ${data.length} items');

      emit(ReceivableLoaded(
        receivables: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        searchCustomer: event.searchCustomer,
        searchInvoice: event.searchInvoice,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e, stackTrace) {
      print('Error in SearchReceivables: $e');
      print('Stack trace: $stackTrace');
      emit(ReceivableError(message: 'Failed to search receivables: $e'));
    }
  }
}
