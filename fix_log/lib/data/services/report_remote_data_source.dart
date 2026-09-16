import '../../domain/models/report.dart';

abstract class ReportRemoteDataSource {
  Future<List<Report>> fetchReports();
  Future<Report> createReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
    double cost,
  );
  Future<Report> updateReport(Report report);
  Future<void> deleteReport(int id);
}
