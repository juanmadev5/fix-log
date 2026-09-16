import '../../../domain/models/report.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState {
  const ReportState({
    this.status = ReportStatus.initial,
    this.reports = const [],
    this.errorMessage,
  });

  final ReportStatus status;
  final List<Report> reports;
  final String? errorMessage;

  bool get isLoading => status == ReportStatus.loading;

  ReportState copyWith({
    ReportStatus? status,
    List<Report>? reports,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      errorMessage: errorMessage,
    );
  }
}
