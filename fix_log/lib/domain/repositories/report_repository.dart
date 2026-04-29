import '../models/report.dart';

abstract class ReportRepository {
  Future<List<Report>> fetchReports();
  Future<Report> createReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
  );
  Future<Report> updateReport(Report report);
  Future<void> deleteReport(int id);
}
