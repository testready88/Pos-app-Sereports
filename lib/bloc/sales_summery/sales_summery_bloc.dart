import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_event.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_state.dart';

import 'package:sereports/repository/sales_repo.dart';

class SalesSummaryBloc extends Bloc<SalesSummaryEvent, SalesSummaryState> {
  final SalesRepo salesRepo;
  final int pageSize = 10;

  SalesSummaryBloc({required this.salesRepo}) : super(SalesSummaryInitial()) {
    on<LoadSalesSummary>(_onLoadSalesSummary);
    on<LoadMoreSalesSummary>(_onLoadMoreSalesSummary);
    on<FilterSalesSummary>(_onFilterSalesSummary);
    on<SearchSalesSummary>(_onSearchSalesSummary);
  }

  Future<void> _onLoadSalesSummary(
    LoadSalesSummary event,
    Emitter<SalesSummaryState> emit,
  ) async {
    try {
      emit(SalesSummaryLoading());

      final response = await salesRepo.getSalesSummary(
        page: 0,
        size: pageSize,
        locaCode: 'All',
        searchCustomer: '',
        paymentType: 'All',
      );

      // Debug logs to check response structure
      print('Sales Response data structure: ${response.keys}');

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

      print('Loaded ${salesData.length} sales records');
      if (salesData.isNotEmpty) {
        print('First sales record fields: ${salesData.first.keys.toList()}');
      }

      emit(SalesSummaryLoaded(
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
        searchCustomer: '',
        locaCode: 'All',
        paymentType: 'All',
      ));
    } catch (e) {
      print('Error in LoadSalesSummary: $e');
      emit(SalesSummaryError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSalesSummary(
    LoadMoreSalesSummary event,
    Emitter<SalesSummaryState> emit,
  ) async {
    if (state is SalesSummaryLoaded) {
      final currentState = state as SalesSummaryLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await salesRepo.getSalesSummary(
          page: nextPage,
          size: pageSize,
          locaCode: currentState.locaCode,
          searchCustomer: currentState.searchCustomer,
          paymentType: currentState.paymentType,
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
        print('Error in LoadMoreSalesSummary: $e');
        emit(SalesSummaryError(e.toString()));
      }
    }
  }

  Future<void> _onFilterSalesSummary(
    FilterSalesSummary event,
    Emitter<SalesSummaryState> emit,
  ) async {
    try {
      emit(SalesSummaryLoading());

      final response = await salesRepo.getSalesSummary(
        page: 0,
        size: pageSize,
        locaCode: event.locaCode,
        searchCustomer: event.searchCustomer,
        paymentType: event.paymentType,
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

      emit(SalesSummaryLoaded(
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
        searchCustomer: event.searchCustomer,
        locaCode: event.locaCode,
        paymentType: event.paymentType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      print('Error in FilterSalesSummary: $e');
      emit(SalesSummaryError(e.toString()));
    }
  }

  Future<void> _onSearchSalesSummary(
    SearchSalesSummary event,
    Emitter<SalesSummaryState> emit,
  ) async {
    try {
      emit(SalesSummaryLoading());

      String searchCustomer = event.searchText;

      // If already in loaded state, preserve other filters
      String locaCode = 'All';
      String paymentType = 'All';
      DateTime? dateFrom;
      DateTime? dateTo;

      if (state is SalesSummaryLoaded) {
        final currentState = state as SalesSummaryLoaded;
        locaCode = currentState.locaCode;
        paymentType = currentState.paymentType;
        dateFrom = currentState.dateFrom;
        dateTo = currentState.dateTo;
      }

      final response = await salesRepo.getSalesSummary(
        page: 0,
        size: pageSize,
        locaCode: locaCode,
        searchCustomer: searchCustomer,
        paymentType: paymentType,
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

      emit(SalesSummaryLoaded(
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
        searchCustomer: searchCustomer,
        locaCode: locaCode,
        paymentType: paymentType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ));
    } catch (e) {
      print('Error in SearchSalesSummary: $e');
      emit(SalesSummaryError(e.toString()));
    }
  }
}
