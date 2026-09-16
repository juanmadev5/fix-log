import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../domain/models/report.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository) : super(const ReportState());

  final ReportRepository _repository;

  Future<void> loadReports() async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final reports = await _repository.fetchReports();
      emit(
        state.copyWith(
          status: ReportStatus.success,
          reports: reports,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          reports: [],
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> addReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
    double cost,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final report = await _repository.createReport(
        customerId,
        date,
        details,
        isCompleted,
        isPaid,
        cost,
      );
      emit(
        state.copyWith(
          status: ReportStatus.success,
          reports: [...state.reports, report],
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> updateReport(Report report) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final updated = await _repository.updateReport(report);
      emit(
        state.copyWith(
          status: ReportStatus.success,
          reports: state.reports
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> deleteReport(int id) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      await _repository.deleteReport(id);
      emit(
        state.copyWith(
          status: ReportStatus.success,
          reports: state.reports.where((item) => item.id != id).toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }
}
