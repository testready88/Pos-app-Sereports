import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_event.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_state.dart';
import 'package:sereports/repository/purchase_repo.dart';

class PurchaseHistoryBloc
    extends Bloc<PurchaseHistoryEvent, PurchaseHistoryState> {
  final PurchaseRepo repo;
  final int pageSize = 10;

  PurchaseHistoryBloc({required this.repo}) : super(PurchaseHistoryInitial()) {
    on<LoadPurchaseHistory>(_onLoadPurchaseHistory);
    on<LoadMorePurchaseHistory>(_onLoadMorePurchaseHistory);
    on<FilterPurchaseHistory>(_onFilterPurchaseHistory);
    on<SearchPurchaseHistory>(_onSearchPurchaseHistory);
  }

  Future<void> _onLoadPurchaseHistory(
    LoadPurchaseHistory event,
    Emitter<PurchaseHistoryState> emit,
  ) async {
    try {
      emit(PurchaseHistoryLoading());

      final response = await repo.getPurchaseDetails(
        page: 0,
        size: pageSize,
        locaCode: 'All',
        searchItem: '',
        searchCategory: '',
        searchSupplier: '',
        purchaseType: 'All',
      );

      // Debug logs to check response structure
      print('Purchase History Response data structure: ${response.keys}');

      final purchaseData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtyPur = (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0;
      final grossPurchase =
          (response['grossPurchase'] as num?)?.toDouble() ?? 0.0;
      final itemDiscountPur =
          (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0;
      final netPurchase = (response['netPurchase'] as num?)?.toDouble() ?? 0.0;
      final transportCharge =
          (response['transportCharge'] as num?)?.toDouble() ?? 0.0;
      final labourCharge =
          (response['labourCharge'] as num?)?.toDouble() ?? 0.0;

      print('Loaded ${purchaseData.length} purchase history records');
      if (purchaseData.isNotEmpty) {
        print(
            'First purchase history record fields: ${purchaseData.first.keys.toList()}');
      }

      emit(PurchaseHistoryLoaded(
        purchaseData: purchaseData,
        count: count,
        totalQtyPur: totalQtyPur,
        grossPurchase: grossPurchase,
        itemDiscountPur: itemDiscountPur,
        netPurchase: netPurchase,
        transportCharge: transportCharge,
        labourCharge: labourCharge,
        hasReachedMax: purchaseData.length < pageSize,
        currentPage: 0,
        searchItem: '',
        searchCategory: '',
        searchSupplier: '',
        locaCode: 'All',
        purchaseType: 'All',
      ));
    } catch (e) {
      print('Error in LoadPurchaseHistory: $e');
      emit(PurchaseHistoryError(e.toString()));
    }
  }

  Future<void> _onLoadMorePurchaseHistory(
    LoadMorePurchaseHistory event,
    Emitter<PurchaseHistoryState> emit,
  ) async {
    if (state is PurchaseHistoryLoaded) {
      final currentState = state as PurchaseHistoryLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;

        // Use the same search parameters from current state
        final response = await repo.getPurchaseDetails(
          page: nextPage,
          size: pageSize,
          locaCode: currentState.locaCode,
          searchItem: currentState.searchItem,
          searchCategory: currentState.searchCategory,
          searchSupplier: currentState.searchSupplier,
          purchaseType: currentState.purchaseType,
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        );

        final newPurchaseData = List<dynamic>.from(response['data'] ?? []);

        print(
            'LoadMore - Page $nextPage loaded ${newPurchaseData.length} items');
        print(
            'LoadMore - Search params: item="${currentState.searchItem}", category="${currentState.searchCategory}", supplier="${currentState.searchSupplier}"');

        if (newPurchaseData.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allPurchaseData = [
            ...currentState.purchaseData,
            ...newPurchaseData
          ];

          emit(currentState.copyWith(
            purchaseData: allPurchaseData,
            currentPage: nextPage,
            hasReachedMax: newPurchaseData.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        print('Error in LoadMorePurchaseHistory: $e');
        emit(PurchaseHistoryError(e.toString()));
      }
    }
  }

  Future<void> _onFilterPurchaseHistory(
    FilterPurchaseHistory event,
    Emitter<PurchaseHistoryState> emit,
  ) async {
    try {
      emit(PurchaseHistoryLoading());

      final response = await repo.getPurchaseDetails(
        page: 0,
        size: pageSize,
        locaCode: event.locaCode,
        searchItem: event.searchItem,
        searchCategory: event.searchCategory,
        searchSupplier: event.searchSupplier,
        purchaseType: event.purchaseType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      final purchaseData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtyPur = (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0;
      final grossPurchase =
          (response['grossPurchase'] as num?)?.toDouble() ?? 0.0;
      final itemDiscountPur =
          (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0;
      final netPurchase = (response['netPurchase'] as num?)?.toDouble() ?? 0.0;
      final transportCharge =
          (response['transportCharge'] as num?)?.toDouble() ?? 0.0;
      final labourCharge =
          (response['labourCharge'] as num?)?.toDouble() ?? 0.0;

      print(
          'Filter applied - Loaded ${purchaseData.length} purchase history records');

      emit(PurchaseHistoryLoaded(
        purchaseData: purchaseData,
        count: count,
        totalQtyPur: totalQtyPur,
        grossPurchase: grossPurchase,
        itemDiscountPur: itemDiscountPur,
        netPurchase: netPurchase,
        transportCharge: transportCharge,
        labourCharge: labourCharge,
        hasReachedMax: purchaseData.length < pageSize,
        currentPage: 0,
        searchItem: event.searchItem,
        searchCategory: event.searchCategory,
        searchSupplier: event.searchSupplier,
        locaCode: event.locaCode,
        purchaseType: event.purchaseType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      print('Error in FilterPurchaseHistory: $e');
      emit(PurchaseHistoryError(e.toString()));
    }
  }

  Future<void> _onSearchPurchaseHistory(
    SearchPurchaseHistory event,
    Emitter<PurchaseHistoryState> emit,
  ) async {
    try {
      emit(PurchaseHistoryLoading());

      String searchItem = event.searchText;

      // If already in loaded state, preserve other filters
      String searchCategory = '';
      String searchSupplier = '';
      String locaCode = 'All';
      String purchaseType = 'All';
      DateTime? dateFrom;
      DateTime? dateTo;

      if (state is PurchaseHistoryLoaded) {
        final currentState = state as PurchaseHistoryLoaded;
        searchCategory = currentState.searchCategory;
        searchSupplier = currentState.searchSupplier;
        locaCode = currentState.locaCode;
        purchaseType = currentState.purchaseType;
        dateFrom = currentState.dateFrom;
        dateTo = currentState.dateTo;
      }

      print('Search triggered with: "$searchItem"');
      print(
          'Other filters preserved: category="$searchCategory", supplier="$searchSupplier", location="$locaCode"');

      final response = await repo.getPurchaseDetails(
        page: 0,
        size: pageSize,
        locaCode: locaCode,
        searchItem: searchItem,
        searchCategory: searchCategory,
        searchSupplier: searchSupplier,
        purchaseType: purchaseType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      final purchaseData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtyPur = (response['totalQtyPur'] as num?)?.toDouble() ?? 0.0;
      final grossPurchase =
          (response['grossPurchase'] as num?)?.toDouble() ?? 0.0;
      final itemDiscountPur =
          (response['itemDiscountPur'] as num?)?.toDouble() ?? 0.0;
      final netPurchase = (response['netPurchase'] as num?)?.toDouble() ?? 0.0;
      final transportCharge =
          (response['transportCharge'] as num?)?.toDouble() ?? 0.0;
      final labourCharge =
          (response['labourCharge'] as num?)?.toDouble() ?? 0.0;

      print(
          'Search completed - Loaded ${purchaseData.length} purchase history records');

      emit(PurchaseHistoryLoaded(
        purchaseData: purchaseData,
        count: count,
        totalQtyPur: totalQtyPur,
        grossPurchase: grossPurchase,
        itemDiscountPur: itemDiscountPur,
        netPurchase: netPurchase,
        transportCharge: transportCharge,
        labourCharge: labourCharge,
        hasReachedMax: purchaseData.length < pageSize,
        currentPage: 0, // Reset to page 0 for new search
        searchItem: searchItem,
        searchCategory: searchCategory,
        searchSupplier: searchSupplier,
        locaCode: locaCode,
        purchaseType: purchaseType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ));
    } catch (e) {
      print('Error in SearchPurchaseHistory: $e');
      emit(PurchaseHistoryError(e.toString()));
    }
  }
}
