import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._dataSource);

  final ExpenseRemoteDataSource _dataSource;

  @override
  Future<Expense> createExpense(
    String title,
    String details,
    double price,
    int quantity,
  ) {
    return _dataSource.createExpense(title, details, price, quantity);
  }

  @override
  Future<void> deleteExpense(int id) {
    return _dataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> fetchExpenses() {
    return _dataSource.fetchExpenses();
  }

  @override
  Future<Expense> updateExpense(Expense expense) {
    return _dataSource.updateExpense(expense);
  }
}
