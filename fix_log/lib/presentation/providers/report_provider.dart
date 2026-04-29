import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/error_handler.dart';
import '../../data/datasources/report_remote_data_source.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/models/report.dart';
import '../../domain/repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required ApiClient apiClient}) {
    _repository = ReportRepositoryImpl(ReportRemoteDataSource(apiClient));
  }

  late final ReportRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  List<Report> _reports = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Report> get reports => _reports;

  Future<void> loadReports() async {
    _setLoading(true);
    try {
      _reports = await _repository.fetchReports();
      _errorMessage = null;
    } catch (error) {
      _reports = [];
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> addReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
  ) async {
    _setLoading(true);
    try {
      final report = await _repository.createReport(
        customerId,
        date,
        details,
        isCompleted,
        isPaid,
      );
      _reports = [..._reports, report];
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> updateReport(Report report) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateReport(report);
      _reports = _reports
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> deleteReport(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteReport(id);
      _reports = _reports.where((item) => item.id != id).toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
