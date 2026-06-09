import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/sales_details/sales_details_event.dart';
import 'package:sereports/bloc/sales_details/sales_details_state.dart';
import 'package:sereports/repository/sales_repo.dart';

class SalesDetailsBloc extends Bloc<SalesDetailsEvent, SalesDetailsState> {
  final SalesRepo salesRepo;
  final int pageSize = 10;

  SalesDetailsBloc({required this.salesRepo}) : super(SalesDetailsInitial()) {
    on<LoadSalesDetails>(_onLoadSalesDetails);
    on<LoadMoreSalesDetails>(_onLoadMoreSalesDetails);
    on<FilterSalesDetails>(_onFilterSalesDetails);
    on<SearchSalesDetails>(_onSearchSalesDetails);
  }

  Future<void> _onLoadSalesDetails(
    LoadSalesDetails event,
    Emitter<SalesDetailsState> emit,
  ) async {
    try {
      emit(SalesDetailsLoading());

      final response = await salesRepo.getSalesDetails(
        page: 0,
        size: pageSize,
        locaCode: 'All',
        searchItem: '',
        searchCategory: '',
        searchSupplier: '',
        salesType: 'All',
      );

      // Debug logs to check response structure
      print('Sales Details Response data structure: ${response.keys}');

      final salesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtySold =
          (response['totalQtySold'] as num?)?.toDouble() ?? 0.0;
      final grossSales = (response['grossSales'] as num?)?.toDouble() ?? 0.0;
      final itemDiscount =
          (response['itemDiscount'] as num?)?.toDouble() ?? 0.0;
      final netSales = (response['netSales'] as num?)?.toDouble() ?? 0.0;
      final profitBeforeDiscount =
          (response['profitBeforeDiscount'] as num?)?.toDouble() ?? 0.0;
      final profitAfterDiscount =
          (response['profitAfterDiscount'] as num?)?.toDouble() ?? 0.0;
      final costSales = (response['costSales'] as num?)?.toDouble() ?? 0.0;
      final exCharges = (response['exCharges'] as num?)?.toDouble() ?? 0.0;
      final advancePayment =
          (response['advancePayment'] as num?)?.toDouble() ?? 0.0;
      final chqPayment = (response['chqPayment'] as num?)?.toDouble() ?? 0.0;
      final cardPayment = (response['cardPayment'] as num?)?.toDouble() ?? 0.0;
      final creditPayment =
          (response['creditPayment'] as num?)?.toDouble() ?? 0.0;
      final cashPayment = (response['cashPayment'] as num?)?.toDouble() ?? 0.0;
      final creditSettlement =
          (response['creditSettlement'] as num?)?.toDouble() ?? 0.0;
      final cashDiscount =
          (response['cashDiscount'] as num?)?.toDouble() ?? 0.0;
      final pointsRedeem =
          (response['pointsRedeem'] as num?)?.toDouble() ?? 0.0;
      final voucherPaid = (response['voucherPaid'] as num?)?.toDouble() ?? 0.0;
      final cashSales = (response['cashSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCashSales =
          (response['profitByCashSales'] as num?)?.toDouble() ?? 0.0;
      final creditSales = (response['creditSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCreditSales =
          (response['profitByCreditSales'] as num?)?.toDouble() ?? 0.0;

      print('Loaded ${salesData.length} sales detail records');
      if (salesData.isNotEmpty) {
        print(
            'First sales detail record fields: ${salesData.first.keys.toList()}');
      }

      emit(SalesDetailsLoaded(
        salesData: salesData,
        count: count,
        totalQtySold: totalQtySold,
        grossSales: grossSales,
        itemDiscount: itemDiscount,
        netSales: netSales,
        profitBeforeDiscount: profitBeforeDiscount,
        profitAfterDiscount: profitAfterDiscount,
        costSales: costSales,
        exCharges: exCharges,
        advancePayment: advancePayment,
        chqPayment: chqPayment,
        cardPayment: cardPayment,
        creditPayment: creditPayment,
        cashPayment: cashPayment,
        creditSettlement: creditSettlement,
        cashDiscount: cashDiscount,
        pointsRedeem: pointsRedeem,
        voucherPaid: voucherPaid,
        cashSales: cashSales,
        profitByCashSales: profitByCashSales,
        creditSales: creditSales,
        profitByCreditSales: profitByCreditSales,
        hasReachedMax: salesData.length < pageSize,
        currentPage: 0,
        searchItem: '',
        searchCategory: '',
        searchSupplier: '',
        locaCode: 'All',
        salesType: 'All',
      ));
    } catch (e) {
      print('Error in LoadSalesDetails: $e');
      emit(SalesDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSalesDetails(
    LoadMoreSalesDetails event,
    Emitter<SalesDetailsState> emit,
  ) async {
    if (state is SalesDetailsLoaded) {
      final currentState = state as SalesDetailsLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await salesRepo.getSalesDetails(
          page: nextPage,
          size: pageSize,
          locaCode: currentState.locaCode,
          searchItem: currentState.searchItem,
          searchCategory: currentState.searchCategory,
          searchSupplier: currentState.searchSupplier,
          salesType: currentState.salesType,
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        );

        final newSalesData = List<dynamic>.from(response['data'] ?? []);

        if (newSalesData.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allSalesData = [...currentState.salesData, ...newSalesData];

          emit(currentState.copyWith(
            salesData: allSalesData,
            currentPage: nextPage,
            hasReachedMax: newSalesData.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        print('Error in LoadMoreSalesDetails: $e');
        emit(SalesDetailsError(e.toString()));
      }
    }
  }

  Future<void> _onFilterSalesDetails(
    FilterSalesDetails event,
    Emitter<SalesDetailsState> emit,
  ) async {
    try {
      emit(SalesDetailsLoading());

      final response = await salesRepo.getSalesDetails(
        page: 0,
        size: pageSize,
        locaCode: event.locaCode,
        searchItem: event.searchItem,
        searchCategory: event.searchCategory,
        searchSupplier: event.searchSupplier,
        salesType: event.salesType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      final salesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtySold =
          (response['totalQtySold'] as num?)?.toDouble() ?? 0.0;
      final grossSales = (response['grossSales'] as num?)?.toDouble() ?? 0.0;
      final itemDiscount =
          (response['itemDiscount'] as num?)?.toDouble() ?? 0.0;
      final netSales = (response['netSales'] as num?)?.toDouble() ?? 0.0;
      final profitBeforeDiscount =
          (response['profitBeforeDiscount'] as num?)?.toDouble() ?? 0.0;
      final profitAfterDiscount =
          (response['profitAfterDiscount'] as num?)?.toDouble() ?? 0.0;
      final costSales = (response['costSales'] as num?)?.toDouble() ?? 0.0;
      final exCharges = (response['exCharges'] as num?)?.toDouble() ?? 0.0;
      final advancePayment =
          (response['advancePayment'] as num?)?.toDouble() ?? 0.0;
      final chqPayment = (response['chqPayment'] as num?)?.toDouble() ?? 0.0;
      final cardPayment = (response['cardPayment'] as num?)?.toDouble() ?? 0.0;
      final creditPayment =
          (response['creditPayment'] as num?)?.toDouble() ?? 0.0;
      final cashPayment = (response['cashPayment'] as num?)?.toDouble() ?? 0.0;
      final creditSettlement =
          (response['creditSettlement'] as num?)?.toDouble() ?? 0.0;
      final cashDiscount =
          (response['cashDiscount'] as num?)?.toDouble() ?? 0.0;
      final pointsRedeem =
          (response['pointsRedeem'] as num?)?.toDouble() ?? 0.0;
      final voucherPaid = (response['voucherPaid'] as num?)?.toDouble() ?? 0.0;
      final cashSales = (response['cashSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCashSales =
          (response['profitByCashSales'] as num?)?.toDouble() ?? 0.0;
      final creditSales = (response['creditSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCreditSales =
          (response['profitByCreditSales'] as num?)?.toDouble() ?? 0.0;

      emit(SalesDetailsLoaded(
        salesData: salesData,
        count: count,
        totalQtySold: totalQtySold,
        grossSales: grossSales,
        itemDiscount: itemDiscount,
        netSales: netSales,
        profitBeforeDiscount: profitBeforeDiscount,
        profitAfterDiscount: profitAfterDiscount,
        costSales: costSales,
        exCharges: exCharges,
        advancePayment: advancePayment,
        chqPayment: chqPayment,
        cardPayment: cardPayment,
        creditPayment: creditPayment,
        cashPayment: cashPayment,
        creditSettlement: creditSettlement,
        cashDiscount: cashDiscount,
        pointsRedeem: pointsRedeem,
        voucherPaid: voucherPaid,
        cashSales: cashSales,
        profitByCashSales: profitByCashSales,
        creditSales: creditSales,
        profitByCreditSales: profitByCreditSales,
        hasReachedMax: salesData.length < pageSize,
        currentPage: 0,
        searchItem: event.searchItem,
        searchCategory: event.searchCategory,
        searchSupplier: event.searchSupplier,
        locaCode: event.locaCode,
        salesType: event.salesType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      print('Error in FilterSalesDetails: $e');
      emit(SalesDetailsError(e.toString()));
    }
  }

  Future<void> _onSearchSalesDetails(
    SearchSalesDetails event,
    Emitter<SalesDetailsState> emit,
  ) async {
    try {
      emit(SalesDetailsLoading());

      String searchItem = event.searchText;

      // If already in loaded state, preserve other filters
      String searchCategory = '';
      String searchSupplier = '';
      String locaCode = 'All';
      String salesType = 'All';
      DateTime? dateFrom;
      DateTime? dateTo;

      if (state is SalesDetailsLoaded) {
        final currentState = state as SalesDetailsLoaded;
        searchCategory = currentState.searchCategory;
        searchSupplier = currentState.searchSupplier;
        locaCode = currentState.locaCode;
        salesType = currentState.salesType;
        dateFrom = currentState.dateFrom;
        dateTo = currentState.dateTo;
      }

      final response = await salesRepo.getSalesDetails(
        page: 0,
        size: pageSize,
        locaCode: locaCode,
        searchItem: searchItem,
        searchCategory: searchCategory,
        searchSupplier: searchSupplier,
        salesType: salesType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      final salesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final totalQtySold =
          (response['totalQtySold'] as num?)?.toDouble() ?? 0.0;
      final grossSales = (response['grossSales'] as num?)?.toDouble() ?? 0.0;
      final itemDiscount =
          (response['itemDiscount'] as num?)?.toDouble() ?? 0.0;
      final netSales = (response['netSales'] as num?)?.toDouble() ?? 0.0;
      final profitBeforeDiscount =
          (response['profitBeforeDiscount'] as num?)?.toDouble() ?? 0.0;
      final profitAfterDiscount =
          (response['profitAfterDiscount'] as num?)?.toDouble() ?? 0.0;
      final costSales = (response['costSales'] as num?)?.toDouble() ?? 0.0;
      final exCharges = (response['exCharges'] as num?)?.toDouble() ?? 0.0;
      final advancePayment =
          (response['advancePayment'] as num?)?.toDouble() ?? 0.0;
      final chqPayment = (response['chqPayment'] as num?)?.toDouble() ?? 0.0;
      final cardPayment = (response['cardPayment'] as num?)?.toDouble() ?? 0.0;
      final creditPayment =
          (response['creditPayment'] as num?)?.toDouble() ?? 0.0;
      final cashPayment = (response['cashPayment'] as num?)?.toDouble() ?? 0.0;
      final creditSettlement =
          (response['creditSettlement'] as num?)?.toDouble() ?? 0.0;
      final cashDiscount =
          (response['cashDiscount'] as num?)?.toDouble() ?? 0.0;
      final pointsRedeem =
          (response['pointsRedeem'] as num?)?.toDouble() ?? 0.0;
      final voucherPaid = (response['voucherPaid'] as num?)?.toDouble() ?? 0.0;
      final cashSales = (response['cashSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCashSales =
          (response['profitByCashSales'] as num?)?.toDouble() ?? 0.0;
      final creditSales = (response['creditSales'] as num?)?.toDouble() ?? 0.0;
      final profitByCreditSales =
          (response['profitByCreditSales'] as num?)?.toDouble() ?? 0.0;

      emit(SalesDetailsLoaded(
        salesData: salesData,
        count: count,
        totalQtySold: totalQtySold,
        grossSales: grossSales,
        itemDiscount: itemDiscount,
        netSales: netSales,
        profitBeforeDiscount: profitBeforeDiscount,
        profitAfterDiscount: profitAfterDiscount,
        costSales: costSales,
        exCharges: exCharges,
        advancePayment: advancePayment,
        chqPayment: chqPayment,
        cardPayment: cardPayment,
        creditPayment: creditPayment,
        cashPayment: cashPayment,
        creditSettlement: creditSettlement,
        cashDiscount: cashDiscount,
        pointsRedeem: pointsRedeem,
        voucherPaid: voucherPaid,
        cashSales: cashSales,
        profitByCashSales: profitByCashSales,
        creditSales: creditSales,
        profitByCreditSales: profitByCreditSales,
        hasReachedMax: salesData.length < pageSize,
        currentPage: 0,
        searchItem: searchItem,
        searchCategory: searchCategory,
        searchSupplier: searchSupplier,
        locaCode: locaCode,
        salesType: salesType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ));
    } catch (e) {
      print('Error in SearchSalesDetails: $e');
      emit(SalesDetailsError(e.toString()));
    }
  }
}
