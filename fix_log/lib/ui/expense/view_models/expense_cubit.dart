import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../domain/models/expense.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit(this._repository) : super(const ExpenseState());

  final ExpenseRepository _repository;

  Future<void> loadExpenses() async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      final expenses = await _repository.fetchExpenses();
      emit(
        state.copyWith(
          status: ExpenseStatus.success,
          expenses: expenses,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ExpenseStatus.failure,
          expenses: [],
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> addExpense(
    String title,
    String details,
    double price,
    int quantity,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      final expense = await _repository.createExpense(
        title,
        details,
        price,
        quantity,
      );
      emit(
        state.copyWith(
          status: ExpenseStatus.success,
          expenses: [...state.expenses, expense],
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ExpenseStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> updateExpense(Expense expense) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      final updated = await _repository.updateExpense(expense);
      emit(
        state.copyWith(
          status: ExpenseStatus.success,
          expenses: state.expenses
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ExpenseStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> deleteExpense(int id) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      await _repository.deleteExpense(id);
      emit(
        state.copyWith(
          status: ExpenseStatus.success,
          expenses: state.expenses.where((item) => item.id != id).toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ExpenseStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }
}
