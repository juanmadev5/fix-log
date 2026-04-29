import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/error_handler.dart';
import '../../data/datasources/customer_remote_data_source.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/models/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider({required ApiClient apiClient}) {
    _repository = CustomerRepositoryImpl(CustomerRemoteDataSource(apiClient));
  }

  late final CustomerRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  List<Customer> _customers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _setLoading(true);
    try {
      _customers = await _repository.fetchCustomers();
      _errorMessage = null;
    } catch (error) {
      _customers = [];
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> addCustomer(
    String name,
    String email,
    String phoneNumber,
  ) async {
    _setLoading(true);
    try {
      final customer = await _repository.createCustomer(
        name,
        email,
        phoneNumber,
      );
      _customers = [..._customers, customer];
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> updateCustomer(Customer customer) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateCustomer(customer);
      _customers = _customers
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> deleteCustomer(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteCustomer(id);
      _customers = _customers.where((item) => item.id != id).toList();
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
