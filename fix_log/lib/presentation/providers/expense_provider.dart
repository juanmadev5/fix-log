import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/error_handler.dart';
import '../../data/datasources/expense_remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({required ApiClient apiClient}) {
    _repository = ExpenseRepositoryImpl(ExpenseRemoteDataSource(apiClient));
  }

  late final ExpenseRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  List<Expense> _expenses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      _expenses = await _repository.fetchExpenses();
      _errorMessage = null;
    } catch (error) {
      _expenses = [];
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> addExpense(
    String title,
    String details,
    double price,
    int quantity,
  ) async {
    _setLoading(true);
    try {
      final expense = await _repository.createExpense(
        title,
        details,
        price,
        quantity,
      );
      _expenses = [..._expenses, expense];
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateExpense(expense);
      _expenses = _expenses
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteExpense(id);
      _expenses = _expenses.where((item) => item.id != id).toList();
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
