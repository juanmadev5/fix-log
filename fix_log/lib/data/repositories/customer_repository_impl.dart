import '../../domain/models/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dataSource);

  final CustomerRemoteDataSource _dataSource;

  @override
  Future<Customer> createCustomer(
    String name,
    String email,
    String phoneNumber,
  ) {
    return _dataSource.createCustomer(name, email, phoneNumber);
  }

  @override
  Future<void> deleteCustomer(int id) {
    return _dataSource.deleteCustomer(id);
  }

  @override
  Future<List<Customer>> fetchCustomers() {
    return _dataSource.fetchCustomers();
  }

  @override
  Future<Customer> updateCustomer(Customer customer) {
    return _dataSource.updateCustomer(customer);
  }
}
