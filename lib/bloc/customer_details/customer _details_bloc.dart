// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/customer_details/customer_details_event.dart';
import 'package:sereports/bloc/customer_details/customer_details_state.dart';
import 'package:sereports/repository/customer_repo.dart';

class CustomerDetailsBloc
    extends Bloc<CustomerDetailsEvent, CustomerDetailsState> {
  final CustomerRepo customerRepo;
  final int pageSize = 10;

  CustomerDetailsBloc({required this.customerRepo})
      : super(CustomerDetailsInitial()) {
    on<LoadCustomerDetails>(_onLoadCustomerDetails);
    on<LoadMoreCustomerDetails>(_onLoadMoreCustomerDetails);
    on<FilterCustomerDetails>(_onFilterCustomerDetails);
    on<SearchCustomer>(_onSearchCustomer);
  }

  Future<void> _onLoadCustomerDetails(
    LoadCustomerDetails event,
    Emitter<CustomerDetailsState> emit,
  ) async {
    try {
      emit(CustomerDetailsLoading());

      final response = await customerRepo.getCustomerDetails(
        page: 0,
        size: pageSize,
        searchText: '',
        invGap: 'All',
        filterCreditAmount: false,
        settlement: 'All',
      );

      // Debug logs to check response structure
      print('Response data structure: ${response.keys}');

      final customers = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;
      // Handle potential null value for totalReceivableAmount
      final totalReceivableAmount = response['totalReceivableAmount'] != null
          ? (response['totalReceivableAmount'] as num).toDouble()
          : 0.0;

      print('Loaded ${customers.length} customers');
      if (customers.isNotEmpty) {
        print('First customer fields: ${customers.first.keys.toList()}');
      }

      emit(CustomerDetailsLoaded(
        customers: customers,
        totalReceivableAmount: totalReceivableAmount,
        count: count,
        hasReachedMax: customers.length < pageSize,
        currentPage: 0,
        searchText: '',
        invGap: 'All',
        filterCreditAmount: false,
        settlement: 'All',
      ));
    } catch (e) {
      print('Error in LoadCustomerDetails: $e');
      emit(CustomerDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreCustomerDetails(
    LoadMoreCustomerDetails event,
    Emitter<CustomerDetailsState> emit,
  ) async {
    if (state is CustomerDetailsLoaded) {
      final currentState = state as CustomerDetailsLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await customerRepo.getCustomerDetails(
          page: nextPage,
          size: pageSize,
          searchText: currentState.searchText,
          invGap: currentState.invGap,
          filterCreditAmount: currentState.filterCreditAmount,
          settlement: currentState.settlement,
        );

        final newCustomers = List<dynamic>.from(response['data'] ?? []);
        final count = response['count'] as int? ?? 0;
        // Handle potential null value for totalReceivableAmount
        final totalReceivableAmount = response['totalReceivableAmount'] != null
            ? (response['totalReceivableAmount'] as num).toDouble()
            : currentState.totalReceivableAmount;

        if (newCustomers.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allCustomers = [...currentState.customers, ...newCustomers];

          emit(currentState.copyWith(
            customers: allCustomers,
            count: count,
            totalReceivableAmount: totalReceivableAmount,
            currentPage: nextPage,
            hasReachedMax: newCustomers.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        print('Error in LoadMoreCustomerDetails: $e');
        emit(CustomerDetailsError(e.toString()));
      }
    }
  }

  Future<void> _onFilterCustomerDetails(
    FilterCustomerDetails event,
    Emitter<CustomerDetailsState> emit,
  ) async {
    try {
      emit(CustomerDetailsLoading());

      final response = await customerRepo.getCustomerDetails(
        page: 0,
        size: pageSize,
        searchText: event.searchText,
        invGap: event.invGap,
        filterCreditAmount: event.filterCreditAmount,
        settlement: event.settlement,
      );

      final customers = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;
      // Handle potential null value for totalReceivableAmount
      final totalReceivableAmount = response['totalReceivableAmount'] != null
          ? (response['totalReceivableAmount'] as num).toDouble()
          : 0.0;

      emit(CustomerDetailsLoaded(
        customers: customers,
        totalReceivableAmount: totalReceivableAmount,
        count: count,
        hasReachedMax: customers.length < pageSize,
        currentPage: 0,
        searchText: event.searchText,
        invGap: event.invGap,
        filterCreditAmount: event.filterCreditAmount,
        settlement: event.settlement,
      ));
    } catch (e) {
      print('Error in FilterCustomerDetails: $e');
      emit(CustomerDetailsError(e.toString()));
    }
  }

  Future<void> _onSearchCustomer(
    SearchCustomer event,
    Emitter<CustomerDetailsState> emit,
  ) async {
    try {
      emit(CustomerDetailsLoading());

      String searchText = event.searchText;

      // If already in loaded state, preserve other filters
      String invGap = 'All';
      bool filterCreditAmount = false;
      String settlement = 'All';

      if (state is CustomerDetailsLoaded) {
        final currentState = state as CustomerDetailsLoaded;
        invGap = currentState.invGap;
        filterCreditAmount = currentState.filterCreditAmount;
        settlement = currentState.settlement;
      }

      final response = await customerRepo.getCustomerDetails(
        page: 0,
        size: pageSize,
        searchText: searchText,
        invGap: invGap,
        filterCreditAmount: filterCreditAmount,
        settlement: settlement,
      );

      final customers = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;
      // Handle potential null value for totalReceivableAmount
      final totalReceivableAmount = response['totalReceivableAmount'] != null
          ? (response['totalReceivableAmount'] as num).toDouble()
          : 0.0;

      emit(CustomerDetailsLoaded(
        customers: customers,
        totalReceivableAmount: totalReceivableAmount,
        count: count,
        hasReachedMax: customers.length < pageSize,
        currentPage: 0,
        searchText: searchText,
        invGap: invGap,
        filterCreditAmount: filterCreditAmount,
        settlement: settlement,
      ));
    } catch (e) {
      print('Error in SearchCustomer: $e');
      emit(CustomerDetailsError(e.toString()));
    }
  }
}
