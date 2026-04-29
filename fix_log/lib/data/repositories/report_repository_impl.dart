import '../../domain/models/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Future<Report> createReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
  ) {
    return _dataSource.createReport(
      customerId,
      date,
      details,
      isCompleted,
      isPaid,
    );
  }

  @override
  Future<void> deleteReport(int id) {
    return _dataSource.deleteReport(id);
  }

  @override
  Future<List<Report>> fetchReports() {
    return _dataSource.fetchReports();
  }

  @override
  Future<Report> updateReport(Report report) {
    return _dataSource.updateReport(report);
  }
}
