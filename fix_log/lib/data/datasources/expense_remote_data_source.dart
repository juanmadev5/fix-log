import 'dart:convert';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../core/app_exception.dart';
import '../../domain/models/expense.dart';
import 'api_response.dart';

class ExpenseRemoteDataSource {
  ExpenseRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Expense>> fetchExpenses() async {
    try {
      final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath');
      final response = await _client.get(uri);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(body, (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => Expense.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      return apiResponse.response;
    } on AppException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Expense> createExpense(
    String title,
    String details,
    double price,
    int quantity,
  ) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath');
    final response = await _client.post(uri, {
      'title': title,
      'details': details,
      'price': price,
      'quantity': quantity,
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Expense.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<Expense> updateExpense(Expense expense) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath');
    final response = await _client.put(uri, expense.toJson());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Expense.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<void> deleteExpense(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath/$id');
    await _client.delete(uri);
  }
}
