import '../../../domain/models/expense.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState {
  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.errorMessage,
  });

  final ExpenseStatus status;
  final List<Expense> expenses;
  final String? errorMessage;

  bool get isLoading => status == ExpenseStatus.loading;

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage,
    );
  }
}
