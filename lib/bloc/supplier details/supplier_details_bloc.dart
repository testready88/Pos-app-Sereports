// ignore_for_file: prefer_is_not_operator

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/supplier%20details/supplier_details_event.dart';
import 'package:sereports/bloc/supplier%20details/supplier_details_state.dart';
import 'package:sereports/repository/supplier_repo.dart';

class SupplierDetailsBloc
    extends Bloc<SupplierDetailsEvent, SupplierDetailsState> {
  final SupplierRepo supplierRepo;
  final int pageSize = 10; // Default page size

  SupplierDetailsBloc({required this.supplierRepo})
      : super(SupplierDetailsInitial()) {
    on<LoadSupplierDetails>(_onLoadSupplierDetails);
    on<LoadMoreSupplierDetails>(_onLoadMoreSupplierDetails);
    on<ResetSupplierDetails>(_onResetSupplierDetails);
  }

  Future<void> _onLoadSupplierDetails(
    LoadSupplierDetails event,
    Emitter<SupplierDetailsState> emit,
  ) async {
    try {
      // For a refresh or new search/filter, we start with loading state
      if (event.refresh || !(state is SupplierDetailsLoaded)) {
        emit(SupplierDetailsLoading());
      } else if (state is SupplierDetailsLoaded) {
        // Just update loading flag for UI feedback
        emit((state as SupplierDetailsLoaded).copyWith(isSearching: true));
      }

      final response = await supplierRepo.getSupplierDetails(
        page: event.page,
        size: event.size,
        supplierSearch: event.supplierSearch,
        creditSearch: event.creditSearch,
        invGap: event.invGap,
        settlementGap: event.settlementGap,
      );

      // Extract data from the repository response
      final supplierList = response['data'] as List<dynamic>;
      final totalCount = response['count'] as int;
      final totalOutstandingAmount =
          (response['totalOutstandingAmount'] as num).toDouble();

      // Determine if we've reached the maximum based on current page results
      final hasReachedMax = supplierList.length < pageSize;

      emit(SupplierDetailsLoaded(
        suppliers: supplierList,
        count: totalCount,
        totalOutstandingAmount: totalOutstandingAmount,
        page: event.page,
        size: event.size,
        supplierSearch: event.supplierSearch,
        creditSearch: event.creditSearch,
        invGap: event.invGap,
        settlementGap: event.settlementGap,
        isSearching: false,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(SupplierDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSupplierDetails(
    LoadMoreSupplierDetails event,
    Emitter<SupplierDetailsState> emit,
  ) async {
    if (state is SupplierDetailsLoaded) {
      final currentState = state as SupplierDetailsLoaded;

      // Don't load more if we've already reached max
      if (currentState.hasReachedMax) return;

      // Set loading indicator but keep current suppliers
      emit(currentState.copyWith(isSearching: true));

      try {
        final nextPage = currentState.page + 1;

        final response = await supplierRepo.getSupplierDetails(
          page: nextPage,
          size: currentState.size,
          supplierSearch: currentState.supplierSearch,
          creditSearch: currentState.creditSearch,
          invGap: currentState.invGap,
          settlementGap: currentState.settlementGap,
        );

        // Extract data from the repository response
        final newSuppliers = response['data'] as List<dynamic>;
        final totalCount = response['count'] as int;
        final totalOutstandingAmount =
            (response['totalOutstandingAmount'] as num).toDouble();

        // If no new suppliers, we've reached max
        if (newSuppliers.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isSearching: false,
          ));
          return;
        }

        // Combine existing and new suppliers
        final allSuppliers = [...currentState.suppliers, ...newSuppliers];

        // Determine if we've reached max based on page size
        final hasReachedMax = newSuppliers.length < pageSize;

        emit(SupplierDetailsLoaded(
          suppliers: allSuppliers,
          count: totalCount,
          totalOutstandingAmount:
              totalOutstandingAmount, // Use API's total amount
          page: nextPage,
          size: currentState.size,
          supplierSearch: currentState.supplierSearch,
          creditSearch: currentState.creditSearch,
          invGap: currentState.invGap,
          settlementGap: currentState.settlementGap,
          isSearching: false,
          hasReachedMax: hasReachedMax,
        ));
      } catch (e) {
        // On error, keep current state but stop loading indicator
        emit(currentState.copyWith(isSearching: false));
      }
    }
  }

  void _onResetSupplierDetails(
    ResetSupplierDetails event,
    Emitter<SupplierDetailsState> emit,
  ) {
    emit(SupplierDetailsInitial());
  }
}
