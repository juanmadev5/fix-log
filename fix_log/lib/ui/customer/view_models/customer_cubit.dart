import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../domain/models/customer.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit(this._repository) : super(const CustomerState());

  final CustomerRepository _repository;

  Future<void> loadCustomers() async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final customers = await _repository.fetchCustomers();
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          customers: customers,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          customers: [],
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> addCustomer(
    String name,
    String email,
    String phoneNumber,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final customer = await _repository.createCustomer(
        name,
        email,
        phoneNumber,
      );
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          customers: [...state.customers, customer],
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final updated = await _repository.updateCustomer(customer);
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          customers: state.customers
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> deleteCustomer(int id) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      await _repository.deleteCustomer(id);
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          customers: state.customers.where((item) => item.id != id).toList(),
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }
}
