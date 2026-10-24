import 'dart:convert';

import '../../domain/models/expense.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import 'expense_remote_data_source.dart';

class ExpenseRemoteDataSourceHttp implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceHttp(this._client);

  final ApiClient _client;

  @override
  Future<List<Expense>> fetchExpenses() async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath?page=1&page_size=100');
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
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
    return Expense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath/${expense.id}');
    final response = await _client.put(uri, expense.toJson());
    return Expense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$expensesPath/$id');
    await _client.delete(uri);
  }
}
