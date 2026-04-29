import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> fetchExpenses();
  Future<Expense> createExpense(
    String title,
    String details,
    double price,
    int quantity,
  );
  Future<Expense> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
}
