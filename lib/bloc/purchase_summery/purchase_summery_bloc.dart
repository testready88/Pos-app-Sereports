import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/purchase_summery/purchase_summery_event.dart';
import 'package:sereports/bloc/purchase_summery/purchase_summery_state.dart';
import 'package:sereports/repository/purchase_repo.dart';

class PurchaseSummaryBloc
    extends Bloc<PurchaseSummaryEvent, PurchaseSummaryState> {
  final PurchaseRepo repo;
  final int pageSize = 10;

  PurchaseSummaryBloc({required this.repo}) : super(PurchaseSummaryInitial()) {
    on<LoadPurchaseSummary>(_onLoadPurchaseSummary);
    on<LoadMorePurchaseSummary>(_onLoadMorePurchaseSummary);
    on<FilterPurchaseSummary>(_onFilterPurchaseSummary);
    on<SearchPurchaseSummary>(_onSearchPurchaseSummary);
  }

  // Load initial data with minimal parameters
  Future<void> _onLoadPurchaseSummary(
    LoadPurchaseSummary event,
    Emitter<PurchaseSummaryState> emit,
  ) async {
    try {
      emit(PurchaseSummaryLoading());

      final response = await repo.getPurchaseSummary(
        page: 0,
        size: pageSize,
        // No hardcoded filters - just get all data initially
      );

      final purchaseSummaryData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      emit(PurchaseSummaryLoaded(
        purchaseSummaryData: purchaseSummaryData,
        count: count,
        totalQtyPur: (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0,
        grossPurchase: (response['grossPurchase'] as num?)?.toDouble() ?? 0.0,
        itemDiscountPur:
            (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0,
        netPurchase: (response['netPurchase'] as num?)?.toDouble() ?? 0.0,
        cashDiscountPur:
            (response['cashDiscountPur'] as num?)?.toDouble() ?? 0.0,
        advancePaymentPur:
            (response['advancePaymentPur'] as num?)?.toDouble() ?? 0.0,
        chqPaymentPur: (response['chqPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cardPaymentPur: (response['cardPaymentPur'] as num?)?.toDouble() ?? 0.0,
        creditPaymentPur:
            (response['creditPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cashPaymentPur: (response['cashPaymentPur'] as num?)?.toDouble() ?? 0.0,
        transportCharge:
            (response['transportCharge'] as num?)?.toDouble() ?? 0.0,
        labourCharge: (response['labourCharge'] as num?)?.toDouble() ?? 0.0,
        hasReachedMax: purchaseSummaryData.length < pageSize,
        currentPage: 0,
        searchSupplier: '',
        searchInvoice: '',
        locaCode: '',
        paymentType: '',
      ));
    } catch (e) {
      emit(PurchaseSummaryError(e.toString()));
    }
  }

  // Simple search - only search supplier parameter
  Future<void> _onSearchPurchaseSummary(
    SearchPurchaseSummary event,
    Emitter<PurchaseSummaryState> emit,
  ) async {
    try {
      emit(PurchaseSummaryLoading());

      final searchText = event.searchText.trim();

      // If search is empty, load all data
      if (searchText.isEmpty) {
        add(const LoadPurchaseSummary());
        return;
      }

      final response = await repo.getPurchaseSummary(
        page: 0,
        size: pageSize,
        searchSupplier: searchText, // Only send search parameter
      );

      final purchaseSummaryData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      emit(PurchaseSummaryLoaded(
        purchaseSummaryData: purchaseSummaryData,
        count: count,
        totalQtyPur: (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0,
        grossPurchase: (response['grossPurchase'] as num?)?.toDouble() ?? 0.0,
        itemDiscountPur:
            (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0,
        netPurchase: (response['netPurchase'] as num?)?.toDouble() ?? 0.0,
        cashDiscountPur:
            (response['cashDiscountPur'] as num?)?.toDouble() ?? 0.0,
        advancePaymentPur:
            (response['advancePaymentPur'] as num?)?.toDouble() ?? 0.0,
        chqPaymentPur: (response['chqPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cardPaymentPur: (response['cardPaymentPur'] as num?)?.toDouble() ?? 0.0,
        creditPaymentPur:
            (response['creditPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cashPaymentPur: (response['cashPaymentPur'] as num?)?.toDouble() ?? 0.0,
        transportCharge:
            (response['transportCharge'] as num?)?.toDouble() ?? 0.0,
        labourCharge: (response['labourCharge'] as num?)?.toDouble() ?? 0.0,
        hasReachedMax: purchaseSummaryData.length < pageSize,
        currentPage: 0,
        searchSupplier: searchText,
        searchInvoice: '',
        locaCode: '',
        paymentType: '',
      ));
    } catch (e) {
      emit(PurchaseSummaryError(e.toString()));
    }
  }

  // Load more with current filters
  Future<void> _onLoadMorePurchaseSummary(
    LoadMorePurchaseSummary event,
    Emitter<PurchaseSummaryState> emit,
  ) async {
    if (state is PurchaseSummaryLoaded) {
      final currentState = state as PurchaseSummaryLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;

        final response = await repo.getPurchaseSummary(
          page: nextPage,
          size: pageSize,
          // Only send parameters that have values
          searchSupplier: currentState.searchSupplier.isNotEmpty
              ? currentState.searchSupplier
              : null,
          searchInvoice: currentState.searchInvoice.isNotEmpty
              ? currentState.searchInvoice
              : null,
          locaCode:
              currentState.locaCode.isNotEmpty && currentState.locaCode != 'All'
                  ? currentState.locaCode
                  : null,
          paymentType: currentState.paymentType.isNotEmpty &&
                  currentState.paymentType != 'All'
              ? currentState.paymentType
              : null,
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        );

        final newData = List<dynamic>.from(response['data'] ?? []);

        if (newData.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isLoading: false));
        } else {
          emit(currentState.copyWith(
            purchaseSummaryData: [
              ...currentState.purchaseSummaryData,
              ...newData
            ],
            currentPage: nextPage,
            hasReachedMax: newData.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(PurchaseSummaryError(e.toString()));
      }
    }
  }

  // Filter with only user-selected parameters
  Future<void> _onFilterPurchaseSummary(
    FilterPurchaseSummary event,
    Emitter<PurchaseSummaryState> emit,
  ) async {
    try {
      emit(PurchaseSummaryLoading());

      final response = await repo.getPurchaseSummary(
        page: 0,
        size: pageSize,
        // Only send filters that user actually set
        searchSupplier: event.searchSupplier.isNotEmpty == true
            ? event.searchSupplier
            : null,
        searchInvoice:
            event.searchInvoice.isNotEmpty == true ? event.searchInvoice : null,
        locaCode: event.locaCode != 'All' ? event.locaCode : null,
        paymentType: event.paymentType != 'All' ? event.paymentType : null,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      final purchaseSummaryData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      emit(PurchaseSummaryLoaded(
        purchaseSummaryData: purchaseSummaryData,
        count: count,
        totalQtyPur: (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0,
        grossPurchase: (response['grossPurchase'] as num?)?.toDouble() ?? 0.0,
        itemDiscountPur:
            (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0,
        netPurchase: (response['netPurchase'] as num?)?.toDouble() ?? 0.0,
        cashDiscountPur:
            (response['cashDiscountPur'] as num?)?.toDouble() ?? 0.0,
        advancePaymentPur:
            (response['advancePaymentPur'] as num?)?.toDouble() ?? 0.0,
        chqPaymentPur: (response['chqPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cardPaymentPur: (response['cardPaymentPur'] as num?)?.toDouble() ?? 0.0,
        creditPaymentPur:
            (response['creditPaymentPur'] as num?)?.toDouble() ?? 0.0,
        cashPaymentPur: (response['cashPaymentPur'] as num?)?.toDouble() ?? 0.0,
        transportCharge:
            (response['transportCharge'] as num?)?.toDouble() ?? 0.0,
        labourCharge: (response['labourCharge'] as num?)?.toDouble() ?? 0.0,
        hasReachedMax: purchaseSummaryData.length < pageSize,
        currentPage: 0,
        searchSupplier: event.searchSupplier,
        searchInvoice: event.searchInvoice,
        locaCode: event.locaCode,
        paymentType: event.paymentType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      emit(PurchaseSummaryError(e.toString()));
    }
  }
}
