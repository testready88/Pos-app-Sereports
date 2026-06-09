import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/customer_debitors/customer_debitor_event.dart';
import 'package:sereports/bloc/customer_debitors/customer_debitor_state.dart';
import 'package:sereports/repository/customer_repo.dart';
import 'dart:async';

class DebitorsBloc extends Bloc<DebitorsEvent, DebitorsState> {
  final CustomerRepo customerRepo;

  DebitorsBloc({required this.customerRepo}) : super(DebitorsInitial()) {
    on<LoadDebitors>(_onLoadDebitors);
    on<LoadMoreDebitors>(_onLoadMoreDebitors);
    on<FilterDebitors>(_onFilterDebitors);
    on<SearchDebitors>(_onSearchDebitors);
  }

  Future<void> _onLoadDebitors(
    LoadDebitors event,
    Emitter<DebitorsState> emit,
  ) async {
    emit(DebitorsLoading());
    try {
      print('Loading initial debitors data');
      final response = await customerRepo.getCustomerDebitors(
        page: 0,
        size: 10,
        searchText: '',
        invGap: 'All',
        settlement: 'All',
        creditAmount: '',
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

      print('Emitting DebitorsLoaded with ${data.length} items');
      // Emit loaded state
      emit(DebitorsLoaded(
        debitors: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
      ));
    } catch (e, stackTrace) {
      print('Error in LoadDebitors: $e');
      print('Stack trace: $stackTrace');
      emit(DebitorsError(message: 'Failed to load debitors: $e'));
    }
  }

  Future<void> _onLoadMoreDebitors(
    LoadMoreDebitors event,
    Emitter<DebitorsState> emit,
  ) async {
    if (state is DebitorsLoaded) {
      final currentState = state as DebitorsLoaded;

      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;

        print('Loading more debitors, page: $nextPage');

        final response = await customerRepo.getCustomerDebitors(
          page: nextPage,
          size: 10,
          searchText: event.searchText,
          invGap: event.invGap,
          settlement: event.settlement,
          creditAmount: event.creditAmount,
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

        emit(DebitorsLoaded(
          debitors: [...currentState.debitors, ...newData],
          totalElements: totalElements,
          currentPage: nextPage,
          hasReachedMax: newData.length < 10,
          totalAmount: totalAmount,
          searchText: event.searchText,
          invGap: event.invGap,
          settlement: event.settlement,
          creditAmount: event.creditAmount,
        ));
      } catch (e, stackTrace) {
        print('Error in LoadMoreDebitors: $e');
        print('Stack trace: $stackTrace');

        // Keep the current state but emit error message
        emit(DebitorsError(message: 'Failed to load more debitors: $e'));

        // Revert to previous loaded state to allow retry
        emit(currentState);
      }
    }
  }

  Future<void> _onFilterDebitors(
    FilterDebitors event,
    Emitter<DebitorsState> emit,
  ) async {
    emit(DebitorsLoading());
    try {
      print('Filtering debitors with criteria: ${event.toString()}');

      final response = await customerRepo.getCustomerDebitors(
        page: 0,
        size: 10,
        searchText: event.searchText,
        invGap: event.invGap,
        settlement: event.settlement,
        creditAmount: event.creditAmount,
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

      emit(DebitorsLoaded(
        debitors: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        searchText: event.searchText,
        invGap: event.invGap,
        settlement: event.settlement,
        creditAmount: event.creditAmount,
      ));
    } catch (e, stackTrace) {
      print('Error in FilterDebitors: $e');
      print('Stack trace: $stackTrace');
      emit(DebitorsError(message: 'Failed to filter debitors: $e'));
    }
  }

  Future<void> _onSearchDebitors(
    SearchDebitors event,
    Emitter<DebitorsState> emit,
  ) async {
    emit(DebitorsLoading());
    try {
      print('Searching debitors with text: ${event.searchText}');

      final response = await customerRepo.getCustomerDebitors(
        page: 0,
        size: 10,
        searchText: event.searchText,
        invGap: 'All',
        settlement: 'All',
        creditAmount: '',
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

      emit(DebitorsLoaded(
        debitors: data,
        totalElements: totalElements,
        currentPage: 0,
        hasReachedMax: data.length < 10,
        totalAmount: totalAmount,
        searchText: event.searchText,
      ));
    } catch (e, stackTrace) {
      print('Error in SearchDebitors: $e');
      print('Stack trace: $stackTrace');
      emit(DebitorsError(message: 'Failed to search debitors: $e'));
    }
  }
}
