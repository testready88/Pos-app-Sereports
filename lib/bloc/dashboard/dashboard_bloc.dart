import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/dashboard/dashboard_event.dart';
import 'package:sereports/bloc/dashboard/dashboard_state.dart';
import 'package:sereports/repository/dashboard_repo.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchDashboardSummary>(_onFetchDashboardSummary);
  }

  Future<void> _onFetchDashboardSummary(
    FetchDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final dashboardData = await repository.getDashboardSummary(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        locationCode: event.locationCode,
      );
      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
