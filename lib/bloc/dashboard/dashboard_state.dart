abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> dashboardData;

  DashboardLoaded(this.dashboardData);
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
