abstract class DashboardEvent {}

class FetchDashboardSummary extends DashboardEvent {
  final String dateFrom;
  final String dateTo;
  final String locationCode;

  FetchDashboardSummary({
    required this.dateFrom,
    required this.dateTo,
    required this.locationCode,
  });
}
