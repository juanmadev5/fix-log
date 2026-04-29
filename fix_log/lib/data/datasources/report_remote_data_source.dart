import 'dart:convert';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../core/app_exception.dart';
import '../../domain/models/report.dart';
import 'api_response.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Report>> fetchReports() async {
    try {
      final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath');
      final response = await _client.get(uri);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(body, (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => Report.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      return apiResponse.response;
    } on AppException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Report> createReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
  ) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath');
    final response = await _client.post(uri, {
      'customerId': customerId,
      'date': date.toIso8601String(),
      'details': details,
      'isCompleted': isCompleted,
      'isPaid': isPaid,
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Report.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<Report> updateReport(Report report) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath');
    final response = await _client.put(uri, report.toJson());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Report.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<void> deleteReport(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath/$id');
    await _client.delete(uri);
  }
}
