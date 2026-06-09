import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/supplier_payable/supplier_payable_event.dart';
import 'package:sereports/bloc/supplier_payable/supplier_payable_state.dart';
import 'package:sereports/repository/supplier_repo.dart';

class SupplierPayableBloc
    extends Bloc<SupplierPayableEvent, SupplierPayableState> {
  final SupplierRepo supplierRepo;
  final int pageSize = 10;

  SupplierPayableBloc({required this.supplierRepo})
      : super(SupplierPayableInitial()) {
    on<LoadSupplierPayables>(_onLoadSupplierPayables);
    on<LoadMoreSupplierPayables>(_onLoadMoreSupplierPayables);
    on<FilterSupplierPayables>(_onFilterSupplierPayables);
    on<SearchSupplierPayable>(_onSearchSupplierPayable);
  }

  Future<void> _onLoadSupplierPayables(
    LoadSupplierPayables event,
    Emitter<SupplierPayableState> emit,
  ) async {
    try {
      emit(SupplierPayableLoading());

      // Default date range is last 12 months to today

      final response = await supplierRepo.getPayableDetails(
        page: 0,
        size: pageSize,
        locaCode: 'All',
        searchSupplier: '',
        searchInvoice: '',
        invGap: 'All',
        dateFrom: null,
        dateTo: null,
      );

      // Handle the nested data structure from API response
      final responseData = response['data'];
      final payables = responseData['data'];

      final count = responseData['count'] as int;
      final totalPayableAmount = responseData['totalOutstandingAmount'] != null
          ? (responseData['totalOutstandingAmount'] as num).toDouble()
          : 0.0;

      emit(SupplierPayableLoaded(
        payables: payables,
        totalPayableAmount: totalPayableAmount,
        count: count,
        hasReachedMax: payables.length < pageSize,
        currentPage: 0,
        supplierSearch: '',
        invoiceNo: '',
        location: 'All',
        invGap: 'All',
        startDate: null,
        endDate: null,
      ));
    } catch (e) {
      print(e);
      emit(SupplierPayableError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSupplierPayables(
    LoadMoreSupplierPayables event,
    Emitter<SupplierPayableState> emit,
  ) async {
    if (state is SupplierPayableLoaded) {
      final currentState = state as SupplierPayableLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await supplierRepo.getPayableDetails(
          page: nextPage,
          size: pageSize,
          locaCode: currentState.location,
          searchSupplier: currentState.supplierSearch,
          searchInvoice: currentState.invoiceNo,
          invGap: currentState.invGap,
          dateFrom: currentState.startDate,
          dateTo: currentState.endDate,
        );

        // Handle the nested data structure from API response
        final responseData = response['data'];
        final payables = responseData['data'];

        final count = responseData['count'] as int;
        final totalPayableAmount =
            (responseData['totalOutstandingAmount'] as num).toDouble();

        if (payables.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allPayables = [...currentState.payables, ...payables];

          emit(currentState.copyWith(
            payables: allPayables,
            count: count,
            totalPayableAmount: totalPayableAmount,
            currentPage: nextPage,
            hasReachedMax: payables.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(SupplierPayableError(e.toString()));
      }
    }
  }

  Future<void> _onFilterSupplierPayables(
    FilterSupplierPayables event,
    Emitter<SupplierPayableState> emit,
  ) async {
    try {
      emit(SupplierPayableLoading());

      final response = await supplierRepo.getPayableDetails(
        page: 0,
        size: pageSize,
        locaCode: event.location,
        searchSupplier: event.supplierSearch,
        searchInvoice: event.invoiceNo,
        invGap: event.invGap,
        dateFrom: event.startDate ??
            DateTime.now().subtract(const Duration(days: 365)),
        dateTo: event.endDate ?? DateTime.now(),
      );

      // Handle the nested data structure from API response

      final responseData = response['data'];
      final payables = responseData['data'];

      final count = responseData['count'] as int;
      final totalPayableAmount =
          (responseData['totalOutstandingAmount'] as num).toDouble();

      emit(SupplierPayableLoaded(
        payables: payables,
        totalPayableAmount: totalPayableAmount,
        count: count,
        hasReachedMax: payables.length < pageSize,
        currentPage: 0,
        supplierSearch: event.supplierSearch,
        invoiceNo: event.invoiceNo,
        location: event.location,
        invGap: event.invGap,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(SupplierPayableError(e.toString()));
    }
  }

  Future<void> _onSearchSupplierPayable(
    SearchSupplierPayable event,
    Emitter<SupplierPayableState> emit,
  ) async {
    try {
      emit(SupplierPayableLoading());

      String supplierSearch = event.searchText;

      // If already in loaded state, preserve other filters
      String invoiceNo = '';
      String location = 'All';
      String invGap = 'All';
      DateTime? startDate;
      DateTime? endDate;

      if (state is SupplierPayableLoaded) {
        final currentState = state as SupplierPayableLoaded;
        invoiceNo = currentState.invoiceNo;
        location = currentState.location;
        invGap = currentState.invGap;
        startDate = currentState.startDate;
        endDate = currentState.endDate;
      } else {
        // Default date range if not previously set
        startDate = DateTime.now().subtract(const Duration(days: 365));
        endDate = DateTime.now();
      }

      final response = await supplierRepo.getPayableDetails(
        page: 0,
        size: pageSize,
        locaCode: location,
        searchSupplier: supplierSearch,
        searchInvoice: invoiceNo,
        invGap: invGap,
        dateFrom: startDate,
        dateTo: endDate,
      );

      // Handle the nested data structure from API response
      final responseData = response['data'];
      final payables = responseData['data'];

      final count = responseData['count'] as int;
      final totalPayableAmount =
          (responseData['totalOutstandingAmount'] as num).toDouble();

      emit(SupplierPayableLoaded(
        payables: payables,
        totalPayableAmount: totalPayableAmount,
        count: count,
        hasReachedMax: payables.length < pageSize,
        currentPage: 0,
        supplierSearch: supplierSearch,
        invoiceNo: invoiceNo,
        location: location,
        invGap: invGap,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      emit(SupplierPayableError(e.toString()));
    }
  }
}
