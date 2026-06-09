import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/incom_expences/incom_expences_event.dart';
import 'package:sereports/bloc/incom_expences/incom_expences_state.dart';
import 'package:sereports/repository/incom_expences_repo.dart';

class IncomeExpensesBloc
    extends Bloc<IncomeExpensesEvent, IncomeExpensesState> {
  final IncomeExpencesRepo repo; // Reusing same repo
  final int pageSize = 10;

  IncomeExpensesBloc({required this.repo}) : super(IncomeExpensesInitial()) {
    on<LoadIncomeExpenses>(_onLoadIncomeExpenses);
    on<LoadMoreIncomeExpenses>(_onLoadMoreIncomeExpenses);
    on<FilterIncomeExpenses>(_onFilterIncomeExpenses);
    on<SearchIncomeExpenses>(_onSearchIncomeExpenses);
  }

  Future<void> _onLoadIncomeExpenses(
    LoadIncomeExpenses event,
    Emitter<IncomeExpensesState> emit,
  ) async {
    try {
      emit(IncomeExpensesLoading());

      final response = await repo.getIncomeExpensesDetails(
        page: 0,
        size: pageSize,
        locaCode: 'All',
        searchDescription: '',
        searchVendor: '',
        invType: 'All',
      );

      // Debug logs to check response structure
      print('Income Expenses Response data structure: ${response.keys}');

      final incomeExpensesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final netIncome = (response['netIncome'] as num?)?.toDouble() ?? 0.0;
      final netExpenses = (response['netExpenses'] as num?)?.toDouble() ?? 0.0;
      final netAmount = netIncome - netExpenses;

      print('Loaded ${incomeExpensesData.length} income expenses records');
      if (incomeExpensesData.isNotEmpty) {
        print(
            'First income expenses record fields: ${incomeExpensesData.first.keys.toList()}');
      }

      emit(IncomeExpensesLoaded(
        incomeExpensesData: incomeExpensesData,
        count: count,
        netIncome: netIncome,
        netExpenses: netExpenses,
        netAmount: netAmount,
        hasReachedMax: incomeExpensesData.length < pageSize,
        currentPage: 0,
        searchDescription: '',
        searchVendor: '',
        locaCode: 'All',
        invType: 'All',
      ));
    } catch (e) {
      print('Error in LoadIncomeExpenses: $e');
      emit(IncomeExpensesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreIncomeExpenses(
    LoadMoreIncomeExpenses event,
    Emitter<IncomeExpensesState> emit,
  ) async {
    if (state is IncomeExpensesLoaded) {
      final currentState = state as IncomeExpensesLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(currentState.copyWith(isLoading: true));

        final nextPage = currentState.currentPage + 1;
        final response = await repo.getIncomeExpensesDetails(
          page: nextPage,
          size: pageSize,
          locaCode: currentState.locaCode,
          searchDescription: currentState.searchDescription,
          searchVendor: currentState.searchVendor,
          invType: currentState.invType,
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        );

        final newIncomeExpensesData =
            List<dynamic>.from(response['data'] ?? []);

        if (newIncomeExpensesData.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoading: false,
          ));
        } else {
          final allIncomeExpensesData = [
            ...currentState.incomeExpensesData,
            ...newIncomeExpensesData
          ];

          emit(currentState.copyWith(
            incomeExpensesData: allIncomeExpensesData,
            currentPage: nextPage,
            hasReachedMax: newIncomeExpensesData.length < pageSize,
            isLoading: false,
          ));
        }
      } catch (e) {
        print('Error in LoadMoreIncomeExpenses: $e');
        emit(IncomeExpensesError(e.toString()));
      }
    }
  }

  Future<void> _onFilterIncomeExpenses(
    FilterIncomeExpenses event,
    Emitter<IncomeExpensesState> emit,
  ) async {
    try {
      emit(IncomeExpensesLoading());

      final response = await repo.getIncomeExpensesDetails(
        page: 0,
        size: pageSize,
        locaCode: event.locaCode,
        searchDescription: event.searchDescription,
        searchVendor: event.searchVendor,
        invType: event.invType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      final incomeExpensesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final netIncome = (response['netIncome'] as num?)?.toDouble() ?? 0.0;
      final netExpenses = (response['netExpenses'] as num?)?.toDouble() ?? 0.0;
      final netAmount = netIncome - netExpenses;

      emit(IncomeExpensesLoaded(
        incomeExpensesData: incomeExpensesData,
        count: count,
        netIncome: netIncome,
        netExpenses: netExpenses,
        netAmount: netAmount,
        hasReachedMax: incomeExpensesData.length < pageSize,
        currentPage: 0,
        searchDescription: event.searchDescription,
        searchVendor: event.searchVendor,
        locaCode: event.locaCode,
        invType: event.invType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      print('Error in FilterIncomeExpenses: $e');
      emit(IncomeExpensesError(e.toString()));
    }
  }

  Future<void> _onSearchIncomeExpenses(
    SearchIncomeExpenses event,
    Emitter<IncomeExpensesState> emit,
  ) async {
    try {
      emit(IncomeExpensesLoading());

      String searchDescription = event.searchText;

      // If already in loaded state, preserve other filters
      String searchVendor = '';
      String locaCode = 'All';
      String invType = 'All';
      DateTime? dateFrom;
      DateTime? dateTo;

      if (state is IncomeExpensesLoaded) {
        final currentState = state as IncomeExpensesLoaded;
        searchVendor = currentState.searchVendor;
        locaCode = currentState.locaCode;
        invType = currentState.invType;
        dateFrom = currentState.dateFrom;
        dateTo = currentState.dateTo;
      }

      final response = await repo.getIncomeExpensesDetails(
        page: 0,
        size: pageSize,
        locaCode: locaCode,
        searchDescription: searchDescription,
        searchVendor: searchVendor,
        invType: invType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      final incomeExpensesData = List<dynamic>.from(response['data'] ?? []);
      final count = response['count'] as int? ?? 0;

      // Extract all the financial data
      final netIncome = (response['netIncome'] as num?)?.toDouble() ?? 0.0;
      final netExpenses = (response['netExpenses'] as num?)?.toDouble() ?? 0.0;
      final netAmount = netIncome - netExpenses;

      emit(IncomeExpensesLoaded(
        incomeExpensesData: incomeExpensesData,
        count: count,
        netIncome: netIncome,
        netExpenses: netExpenses,
        netAmount: netAmount,
        hasReachedMax: incomeExpensesData.length < pageSize,
        currentPage: 0,
        searchDescription: searchDescription,
        searchVendor: searchVendor,
        locaCode: locaCode,
        invType: invType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ));
    } catch (e) {
      print('Error in SearchIncomeExpenses: $e');
      emit(IncomeExpensesError(e.toString()));
    }
  }
}
