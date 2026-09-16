import 'dart:convert';

import '../../domain/models/report.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import 'report_remote_data_source.dart';

class ReportRemoteDataSourceHttp implements ReportRemoteDataSource {
  ReportRemoteDataSourceHttp(this._client);

  final ApiClient _client;

  @override
  Future<List<Report>> fetchReports() async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath?page=1&pageSize=100');
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Report> createReport(
    int customerId,
    DateTime date,
    String details,
    bool isCompleted,
    bool isPaid,
    double cost,
  ) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath');
    final response = await _client.post(uri, {
      'customerId': customerId,
      'date': date.toIso8601String(),
      'details': details,
      'isCompleted': isCompleted,
      'isPaid': isPaid,
      'cost': cost,
    });
    return Report.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Report> updateReport(Report report) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath/${report.id}');
    final response = await _client.put(uri, report.toJson());
    return Report.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReport(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$reportsPath/$id');
    await _client.delete(uri);
  }
}
